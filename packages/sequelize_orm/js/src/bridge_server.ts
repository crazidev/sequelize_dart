/**
 * Unified Sequelize bridge server.
 *
 * Supports three execution modes in a single bundle:
 * 1. QuickJS in-process FFI mode (exposes globalThis.handleRequest / handleCleanup / _encodeMsgPack)
 * 2. Node.js Worker Thread mode (dart2js): Communicates via parentPort.postMessage
 * 3. Node.js stdio mode (Dart VM): Communicates via process.stdin/stdout with MessagePack
 */
import { parentPort } from 'worker_threads';
import { encode } from '@msgpack/msgpack';
import {
  processRequest,
  cleanup,
  JsonRpcRequest,
  JsonRpcResponse,
} from './request_handler';
import { setNotificationCallback } from './utils/state';
import { setHostCall } from './utils/sqlite_driver';
import { format } from 'util';

// ── Environment Detection ───────────────────────────────────────────────────
const isNode = typeof process !== 'undefined' && Boolean(process.versions?.node);
const isWorkerThread = typeof parentPort !== 'undefined' && parentPort !== null;
const isQuickJS = typeof (globalThis as any)._ffiNotify === 'function' || !isNode;

// Expose MessagePack encoder globally for FFI direct binary transport
(globalThis as any)._encodeMsgPack = encode;

// ── Unified Direct Request Handler (QuickJS in-process FFI) ─────────────────
async function handleRequest(
  method: string,
  params: any,
): Promise<JsonRpcResponse> {
  return new Promise<JsonRpcResponse>((resolve) => {
    const request: JsonRpcRequest = { id: 0, method, params };
    processRequest(request, (response) => {
      resolve(response);
    }).catch((err: any) => {
      resolve({
        id: 0,
        error: {
          message: err?.message ?? String(err),
          stack: err?.stack,
        },
      });
    });
  });
}

(globalThis as any).handleRequest = handleRequest;
(globalThis as any).handleCleanup = async function (): Promise<void> {
  await cleanup();
};

// ── Mode-Specific Setup ─────────────────────────────────────────────────────

if (isQuickJS) {
  // ── QuickJS Mode: Wire notifications and SQLite host call via direct FFI ──
  setNotificationCallback((notification) => {
    if (typeof (globalThis as any)._ffiNotify === 'function') {
      (globalThis as any)._ffiNotify('_dart_notification', JSON.stringify(notification));
    }
  });

  setHostCall(async (method: string, params: any) => {
    const sqlite = (globalThis as any)._native_sqlite;
    if (sqlite) {
      if (method === 'sqlite_open') {
        const handle = sqlite.open(params.storage || ':memory:');
        return { handle };
      }
      if (method === 'sqlite_query') {
        return sqlite.query(params.handle, params.sql, params.params || []);
      }
      if (method === 'sqlite_run') {
        return sqlite.run(params.handle, params.sql, params.params || []);
      }
      if (method === 'sqlite_exec') {
        sqlite.exec(params.handle, params.sql);
        return null;
      }
      if (method === 'sqlite_close') {
        sqlite.close(params.handle);
        return null;
      }
    }

    if (typeof (globalThis as any)._ffiHostCall === 'function') {
      const res = (globalThis as any)._ffiHostCall(method, JSON.stringify(params || {}));
      return res ? JSON.parse(res) : null;
    }

    throw new Error(`Host call is not configured for ${method}`);
  });
} else {
  // ── Node.js Mode (Worker Thread or Stdio child process) ───────────────────

  let nextHostCallId = 1;
  const pendingHostCalls = new Map<number, { resolve: (res: any) => void; reject: (err: any) => void }>();

  function sendHostCall(method: string, params: any): Promise<any> {
    return new Promise((resolve, reject) => {
      const callId = nextHostCallId++;
      pendingHostCalls.set(callId, { resolve, reject });
      if (isWorkerThread) {
        parentPort!.postMessage({
          notification: 'host_call',
          callId,
          method,
          params,
        });
      } else {
        const packed = encode({
          notification: 'host_call',
          callId,
          method,
          params,
        });
        const lenBuf = Buffer.allocUnsafe(4);
        lenBuf.writeUInt32BE(packed.length, 0);
        process.stdout.write(Buffer.concat([lenBuf, packed]));
      }
    });
  }

  function handleHostCallResponse(response: any) {
    const { callId, result, error } = response;
    const pending = pendingHostCalls.get(callId);
    if (pending) {
      pendingHostCalls.delete(callId);
      if (error) {
        const errMsg = typeof error === 'string' ? error : error?.message || String(error);
        pending.reject(new Error(errMsg));
      } else {
        pending.resolve(result);
      }
    }
  }

  setHostCall(sendHostCall);

  // Override console methods to send logs as notifications
  function sendLog(level: string, args: any[]) {
    const message = format(...args);
    const notification = { notification: 'log', level, message };

    if (isWorkerThread) {
      parentPort!.postMessage(notification);
    } else {
      process.stdout.write(JSON.stringify(notification) + '\n');
    }
  }

  console.log = (...args: any[]) => sendLog('log', args);
  console.info = (...args: any[]) => sendLog('info', args);
  console.warn = (...args: any[]) => sendLog('warn', args);

  type SendFunction = (response: JsonRpcResponse) => void;
  let sendResponse: SendFunction;

  if (isWorkerThread) {
    // Worker Thread mode (dart2js)
    const port = parentPort!;

    sendResponse = (response: JsonRpcResponse) => {
      port.postMessage(response);
    };

    setNotificationCallback((notification) => {
      port.postMessage(notification);
    });

    port.postMessage({ id: 0, result: { ready: true } });

    port.on('message', async (message: any) => {
      if (message && message.notification_response) {
        handleHostCallResponse(message);
        return;
      }
      await processRequest(message as JsonRpcRequest, sendResponse);
    });

    port.on('close', async () => {
      await cleanup();
    });

    process.on('uncaughtException', (error: Error) => {
      port.postMessage({
        id: null,
        error: {
          message: `Uncaught exception: ${error.message}`,
          stack: error.stack,
        },
      });
    });

    process.on('unhandledRejection', (reason: any) => {
      port.postMessage({
        id: null,
        error: {
          message: `Unhandled rejection: ${reason?.message || reason}`,
          stack: reason?.stack,
        },
      });
    });
  } else {
    // stdio mode (Dart VM)
    const writeMsgPackFrame = (data: any) => {
      const packed = encode(data);
      const lenBuf = Buffer.allocUnsafe(4);
      lenBuf.writeUInt32BE(packed.length, 0);
      process.stdout.write(Buffer.concat([lenBuf, packed]));
    };

    sendResponse = (response: JsonRpcResponse) => {
      writeMsgPackFrame(response);
    };

    setNotificationCallback((notification) => {
      writeMsgPackFrame(notification);
    });

    sendResponse({ id: 0, result: { ready: true } });

    let buffer = '';
    process.stdin.setEncoding('utf8');

    process.stdin.on('data', (chunk: string) => {
      buffer += chunk;
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      for (const line of lines) {
        if (line.trim()) {
          try {
            const message = JSON.parse(line);
            if (message.notification_response) {
              handleHostCallResponse(message);
              continue;
            }
            const request = message as JsonRpcRequest;
            processRequest(request, sendResponse).catch((error: any) => {
              sendResponse({
                id: (request as any).id || null,
                error: {
                  message: `Handler error: ${error.message}`,
                  stack: error.stack,
                },
              });
            });
          } catch (error: any) {
            sendResponse({
              id: null,
              error: {
                message: `Parse error: ${error.message}`,
                code: -32700,
              },
            });
          }
        }
      }
    });

    async function cleanupAndExit(): Promise<void> {
      await cleanup();
      process.exit(0);
    }

    process.stdin.on('end', () => {
      cleanupAndExit().catch(() => process.exit(0));
    });

    process.on('SIGTERM', () => {
      cleanupAndExit().catch(() => process.exit(0));
    });

    process.on('SIGINT', () => {
      cleanupAndExit().catch(() => process.exit(0));
    });
  }
}
