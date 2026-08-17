/**
 * QuickJS in-process bridge entry point.
 *
 * This module is bundled separately from the stdio/worker-thread bridge.
 * It exposes a single `globalThis.handleRequest(method, params)` async
 * function that the Dart QuickJsRuntime calls via `callAsync()`.
 */
import {
  processRequest,
  cleanup,
  JsonRpcRequest,
  JsonRpcResponse,
} from './request_handler';
import { setNotificationCallback } from './utils/state';

// Wire SQL logging and notifications back to Dart via _ffiNotify
setNotificationCallback((notification) => {
  if (typeof (globalThis as any)._ffiNotify === 'function') {
    (globalThis as any)._ffiNotify('_dart_notification', JSON.stringify(notification));
  }
});

// ── Promise-based wrapper ─────────────────────────────────────────────────────

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

// Expose globally so QuickJsRuntime.callAsync() can invoke it.
(globalThis as any).handleRequest = handleRequest;

// Expose cleanup for graceful shutdown called by QuickJsBridgeClient.close().
(globalThis as any).handleCleanup = async function (): Promise<void> {
  await cleanup();
};
