import { EventEmitter } from 'events';

type HostCallFn = (method: string, params: any) => Promise<any>;

let globalHostCall: HostCallFn | null = null;

export function setHostCall(fn: HostCallFn) {
  globalHostCall = fn;
}

export function getHostCall(): HostCallFn {
  if (globalHostCall) return globalHostCall;
  return (method, params) => {
    throw new Error(`Host call is not configured for ${method}`);
  };
}

export class SqliteDatabase extends EventEmitter {
  filename: string;
  _handle: number | null = null;
  open: boolean = false;

  constructor(filename: string, mode?: any, callback?: any) {
    super();
    if (typeof mode === 'function') {
      callback = mode;
      mode = 6;
    }
    this.filename = filename || ':memory:';

    const host = getHostCall();
    host('sqlite_open', { storage: this.filename, mode })
      .then((res: any) => {
        this._handle = res.handle;
        this.open = true;
        if (callback) queueMicrotask(() => callback(null));
      })
      .catch((err: any) => {
        if (callback) queueMicrotask(() => callback(err));
      });
  }

  close(callback?: (err: any) => void) {
    if (this._handle !== null && this._handle !== undefined) {
      const host = getHostCall();
      host('sqlite_close', { handle: this._handle })
        .then(() => {
          this._handle = null;
          this.open = false;
          if (callback) queueMicrotask(() => callback(null));
        })
        .catch((err: any) => {
          if (callback) queueMicrotask(() => callback(err));
        });
    } else if (callback) {
      queueMicrotask(() => callback(null));
    }
  }

  all(sql: string, params?: any, callback?: any) {
    if (typeof params === 'function') {
      callback = params;
      params = [];
    }
    const host = getHostCall();
    host('sqlite_query', { handle: this._handle, sql, params: params || [] })
      .then((rows: any) => {
        if (callback) queueMicrotask(() => callback.call(this, null, rows || []));
      })
      .catch((err: any) => {
        if (callback) queueMicrotask(() => callback.call(this, err));
      });
    return this;
  }

  get(sql: string, params?: any, callback?: any) {
    if (typeof params === 'function') {
      callback = params;
      params = [];
    }
    const host = getHostCall();
    host('sqlite_query', { handle: this._handle, sql, params: params || [] })
      .then((rows: any) => {
        const row = rows && rows.length > 0 ? rows[0] : undefined;
        if (callback) queueMicrotask(() => callback.call(this, null, row));
      })
      .catch((err: any) => {
        if (callback) queueMicrotask(() => callback.call(this, err));
      });
    return this;
  }

  run(sql: string, params?: any, callback?: any) {
    if (typeof params === 'function') {
      callback = params;
      params = [];
    }
    const host = getHostCall();
    host('sqlite_run', { handle: this._handle, sql, params: params || [] })
      .then((res: any) => {
        const ctx = {
          lastID: res?.lastID ?? 0,
          changes: res?.changes ?? 0,
        };
        if (callback) queueMicrotask(() => callback.call(ctx, null));
      })
      .catch((err: any) => {
        if (callback) queueMicrotask(() => callback.call(this, err));
      });
    return this;
  }

  exec(sql: string, callback?: (err: any) => void) {
    const host = getHostCall();
    host('sqlite_exec', { handle: this._handle, sql })
      .then(() => {
        if (callback) queueMicrotask(() => callback.call(this, null));
      })
      .catch((err: any) => {
        if (callback) queueMicrotask(() => callback.call(this, err));
      });
    return this;
  }

  serialize(callback?: () => void) {
    if (typeof callback === 'function') callback();
    return this;
  }

  parallelize(callback?: () => void) {
    if (typeof callback === 'function') callback();
    return this;
  }

  configure(option: any, value: any) {
    return this;
  }

  interrupt() {
    return this;
  }
}

export const OPEN_READONLY = 1;
export const OPEN_READWRITE = 2;
export const OPEN_CREATE = 4;
export const OPEN_FULLMUTEX = 0x00010000;
export const OPEN_URI = 0x00000040;
export const OPEN_SHAREDCACHE = 0x00020000;
export const OPEN_PRIVATECACHE = 0x00040000;
export const Database = SqliteDatabase;
export const verbose = () => sqlite3Shim;

export const sqlite3Shim = {
  Database: SqliteDatabase,
  OPEN_READONLY,
  OPEN_READWRITE,
  OPEN_CREATE,
  OPEN_FULLMUTEX,
  OPEN_URI,
  OPEN_SHAREDCACHE,
  OPEN_PRIVATECACHE,
  verbose,
};

export default sqlite3Shim;
