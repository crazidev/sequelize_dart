#include "quickjs.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#if defined(_WIN32)
#define QJS_EXPORT __declspec(dllexport)
#else
#define QJS_EXPORT __attribute__((visibility("default")))
#endif

typedef struct {
    JSRuntime *rt;
    JSContext *ctx;
} QjsDartRuntime;

typedef const char* (*DartBridgeCallback)(const char* name, const char* argsJson);

static DartBridgeCallback g_dart_callback = NULL;

static JSValue js_ffi_notify(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2 || !g_dart_callback) {
        return JS_UNDEFINED;
    }
    const char *name = JS_ToCString(ctx, argv[0]);
    const char *args = JS_ToCString(ctx, argv[1]);
    if (!name || !args) {
        if (name) JS_FreeCString(ctx, name);
        if (args) JS_FreeCString(ctx, args);
        return JS_UNDEFINED;
    }

    const char *res = g_dart_callback(name, args);
    JS_FreeCString(ctx, name);
    JS_FreeCString(ctx, args);

    if (res) {
        JSValue val = JS_NewString(ctx, res);
        free((void*)res);
        return val;
    }
    return JS_UNDEFINED;
}

QJS_EXPORT void qjs_dart_set_callback(DartBridgeCallback cb) {
    g_dart_callback = cb;
}

static JSValue js_print(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    for (int i = 0; i < argc; i++) {
        const char *str = JS_ToCString(ctx, argv[i]);
        if (str) {
            if (i > 0) printf(" ");
            printf("%s", str);
            JS_FreeCString(ctx, str);
        }
    }
    printf("\n");
    fflush(stdout);
    return JS_UNDEFINED;
}

static JSValue js_require(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_UNDEFINED;
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue req_fn = JS_GetPropertyStr(ctx, global, "_js_require");
    JSValue ret = JS_UNDEFINED;
    if (JS_IsFunction(ctx, req_fn)) {
        ret = JS_Call(ctx, req_fn, global, argc, argv);
    }
    JS_FreeValue(ctx, req_fn);
    JS_FreeValue(ctx, global);
    return ret;
}

#include <sqlite3.h>

#define MAX_SQLITE_DBS 32
static sqlite3* g_sqlite_dbs[MAX_SQLITE_DBS] = {0};

static int sqlite_find_free_slot(void) {
    for (int i = 0; i < MAX_SQLITE_DBS; i++) {
        if (!g_sqlite_dbs[i]) return i;
    }
    return -1;
}

static JSValue js_sqlite_open(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_EXCEPTION;
    const char *path = JS_ToCString(ctx, argv[0]);
    if (!path) return JS_EXCEPTION;

    int slot = sqlite_find_free_slot();
    if (slot < 0) {
        JS_FreeCString(ctx, path);
        return JS_ThrowInternalError(ctx, "Max SQLite databases reached");
    }

    sqlite3 *db = NULL;
    int rc = sqlite3_open(path, &db);
    JS_FreeCString(ctx, path);

    if (rc != SQLITE_OK) {
        const char *err = db ? sqlite3_errmsg(db) : "Failed to open sqlite database";
        if (db) sqlite3_close(db);
        return JS_ThrowInternalError(ctx, "%s", err);
    }

    g_sqlite_dbs[slot] = db;
    return JS_NewInt32(ctx, slot);
}

static JSValue js_sqlite_close(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_UNDEFINED;
    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot >= 0 && slot < MAX_SQLITE_DBS && g_sqlite_dbs[slot]) {
        sqlite3_close(g_sqlite_dbs[slot]);
        g_sqlite_dbs[slot] = NULL;
    }
    return JS_UNDEFINED;
}

static void sqlite_bind_param(sqlite3_stmt *stmt, int idx, JSContext *ctx, JSValueConst val) {
    if (JS_IsNull(val) || JS_IsUndefined(val)) {
        sqlite3_bind_null(stmt, idx);
    } else if (JS_IsBool(val)) {
        sqlite3_bind_int(stmt, idx, JS_ToBool(ctx, val));
    } else if (JS_IsNumber(val)) {
        double d;
        JS_ToFloat64(ctx, &d, val);
        if (d == (int64_t)d) {
            sqlite3_bind_int64(stmt, idx, (int64_t)d);
        } else {
            sqlite3_bind_double(stmt, idx, d);
        }
    } else {
        const char *str = JS_ToCString(ctx, val);
        if (str) {
            sqlite3_bind_text(stmt, idx, str, -1, SQLITE_TRANSIENT);
            JS_FreeCString(ctx, str);
        } else {
            sqlite3_bind_null(stmt, idx);
        }
    }
}

static void sqlite_bind_all_params(sqlite3_stmt *stmt, JSContext *ctx, JSValueConst params) {
    if (JS_IsNull(params) || JS_IsUndefined(params)) return;

    if (JS_IsArray(ctx, params)) {
        int len = 0;
        JSValue lenVal = JS_GetPropertyStr(ctx, params, "length");
        JS_ToInt32(ctx, &len, lenVal);
        JS_FreeValue(ctx, lenVal);
        for (int i = 0; i < len; i++) {
            JSValue elem = JS_GetPropertyUint32(ctx, params, i);
            sqlite_bind_param(stmt, i + 1, ctx, elem);
            JS_FreeValue(ctx, elem);
        }
    } else if (JS_IsObject(params)) {
        JSPropertyEnum *tab = NULL;
        uint32_t len = 0;
        if (JS_GetOwnPropertyNames(ctx, &tab, &len, params, JS_GPN_STRING_MASK) >= 0) {
            for (uint32_t i = 0; i < len; i++) {
                const char *key = JS_AtomToCString(ctx, tab[i].atom);
                if (key) {
                    int idx = sqlite3_bind_parameter_index(stmt, key);
                    if (idx == 0 && key[0] != '$' && key[0] != ':' && key[0] != '@') {
                        char prefixed[256];
                        snprintf(prefixed, sizeof(prefixed), "$%s", key);
                        idx = sqlite3_bind_parameter_index(stmt, prefixed);
                        if (idx == 0) {
                            snprintf(prefixed, sizeof(prefixed), ":%s", key);
                            idx = sqlite3_bind_parameter_index(stmt, prefixed);
                        }
                    }
                    if (idx > 0) {
                        JSValue val = JS_GetProperty(ctx, params, tab[i].atom);
                        sqlite_bind_param(stmt, idx, ctx, val);
                        JS_FreeValue(ctx, val);
                    }
                    JS_FreeCString(ctx, key);
                }
                JS_FreeAtom(ctx, tab[i].atom);
            }
            js_free(ctx, tab);
        }
    }
}

static JSValue js_sqlite_query(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !g_sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }
    sqlite3 *db = g_sqlite_dbs[slot];

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    JS_FreeCString(ctx, sql);

    if (rc != SQLITE_OK) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(db));
    }

    if (argc >= 3) {
        sqlite_bind_all_params(stmt, ctx, argv[2]);
    }

    JSValue rows = JS_NewArray(ctx);
    int col_count = sqlite3_column_count(stmt);
    uint32_t row_idx = 0;

    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        JSValue row = JS_NewObject(ctx);
        for (int i = 0; i < col_count; i++) {
            const char *col_name = sqlite3_column_name(stmt, i);
            int col_type = sqlite3_column_type(stmt, i);
            JSValue val;
            switch (col_type) {
                case SQLITE_INTEGER:
                    val = JS_NewInt64(ctx, sqlite3_column_int64(stmt, i));
                    break;
                case SQLITE_FLOAT:
                    val = JS_NewFloat64(ctx, sqlite3_column_double(stmt, i));
                    break;
                case SQLITE_TEXT:
                    val = JS_NewString(ctx, (const char*)sqlite3_column_text(stmt, i));
                    break;
                case SQLITE_BLOB: {
                    const void *blob = sqlite3_column_blob(stmt, i);
                    int bytes = sqlite3_column_bytes(stmt, i);
                    val = JS_NewArrayBufferCopy(ctx, (const uint8_t*)blob, bytes);
                    break;
                }
                case SQLITE_NULL:
                default:
                    val = JS_NULL;
                    break;
            }
            JS_SetPropertyStr(ctx, row, col_name, val);
        }
        JS_SetPropertyUint32(ctx, rows, row_idx++, row);
    }

    sqlite3_finalize(stmt);

    if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
        JS_FreeValue(ctx, rows);
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(db));
    }

    return rows;
}

static JSValue js_sqlite_run(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !g_sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }
    sqlite3 *db = g_sqlite_dbs[slot];

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    JS_FreeCString(ctx, sql);

    if (rc != SQLITE_OK) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(db));
    }

    if (argc >= 3) {
        sqlite_bind_all_params(stmt, ctx, argv[2]);
    }

    rc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(db));
    }

    JSValue res = JS_NewObject(ctx);
    JS_SetPropertyStr(ctx, res, "lastID", JS_NewInt64(ctx, sqlite3_last_insert_rowid(db)));
    JS_SetPropertyStr(ctx, res, "changes", JS_NewInt32(ctx, sqlite3_changes(db)));
    return res;
}

static JSValue js_sqlite_exec(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !g_sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }
    sqlite3 *db = g_sqlite_dbs[slot];

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    char *err_msg = NULL;
    int rc = sqlite3_exec(db, sql, NULL, NULL, &err_msg);
    JS_FreeCString(ctx, sql);

    if (rc != SQLITE_OK) {
        JSValue err = JS_ThrowInternalError(ctx, "%s", err_msg ? err_msg : "SQLite exec error");
        if (err_msg) sqlite3_free(err_msg);
        return err;
    }
    return JS_UNDEFINED;
}

QJS_EXPORT QjsDartRuntime* qjs_dart_create_runtime(void) {
    QjsDartRuntime *handle = (QjsDartRuntime*)malloc(sizeof(QjsDartRuntime));
    if (!handle) return NULL;

    handle->rt = JS_NewRuntime();
    if (!handle->rt) {
        free(handle);
        return NULL;
    }

    handle->ctx = JS_NewContext(handle->rt);
    if (!handle->ctx) {
        JS_FreeRuntime(handle->rt);
        free(handle);
        return NULL;
    }

    JSValue global = JS_GetGlobalObject(handle->ctx);

    // Register _ffiNotify
    JSValue notify_fn = JS_NewCFunction(handle->ctx, js_ffi_notify, "_ffiNotify", 2);
    JS_SetPropertyStr(handle->ctx, global, "_ffiNotify", notify_fn);

    // Register global require
    JSValue req_fn = JS_NewCFunction(handle->ctx, js_require, "require", 1);
    JS_SetPropertyStr(handle->ctx, global, "require", req_fn);

    // Register native SQLite bindings
    JSValue sqlite_obj = JS_NewObject(handle->ctx);
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "open", JS_NewCFunction(handle->ctx, js_sqlite_open, "open", 1));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "close", JS_NewCFunction(handle->ctx, js_sqlite_close, "close", 1));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "query", JS_NewCFunction(handle->ctx, js_sqlite_query, "query", 3));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "run", JS_NewCFunction(handle->ctx, js_sqlite_run, "run", 3));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "exec", JS_NewCFunction(handle->ctx, js_sqlite_exec, "exec", 2));
    JS_SetPropertyStr(handle->ctx, global, "_native_sqlite", sqlite_obj);

    // Register basic console.log
    JSValue console = JS_NewObject(handle->ctx);
    JS_SetPropertyStr(handle->ctx, console, "log", JS_NewCFunction(handle->ctx, js_print, "log", 1));
    JS_SetPropertyStr(handle->ctx, console, "info", JS_NewCFunction(handle->ctx, js_print, "info", 1));
    JS_SetPropertyStr(handle->ctx, console, "warn", JS_NewCFunction(handle->ctx, js_print, "warn", 1));
    JS_SetPropertyStr(handle->ctx, console, "error", JS_NewCFunction(handle->ctx, js_print, "error", 1));
    JS_SetPropertyStr(handle->ctx, global, "console", console);

    JS_FreeValue(handle->ctx, global);

    return handle;
}

QJS_EXPORT void qjs_dart_free_runtime(QjsDartRuntime *handle) {
    if (!handle) return;
    if (handle->ctx) JS_FreeContext(handle->ctx);
    if (handle->rt) JS_FreeRuntime(handle->rt);
    free(handle);
}

QJS_EXPORT const char* qjs_dart_eval(QjsDartRuntime *handle, const char* jsCode) {
    if (!handle || !handle->ctx || !jsCode) return NULL;

    JSValue val = JS_Eval(handle->ctx, jsCode, strlen(jsCode), "<eval>", JS_EVAL_TYPE_GLOBAL);
    char *result_str = NULL;

    if (JS_IsException(val)) {
        JSValue exc = JS_GetException(handle->ctx);
        JSValue stack = JS_GetPropertyStr(handle->ctx, exc, "stack");
        const char *str = NULL;
        if (!JS_IsUndefined(stack)) {
            str = JS_ToCString(handle->ctx, stack);
        }
        if (!str) {
            str = JS_ToCString(handle->ctx, exc);
        }
        if (str) {
            result_str = strdup(str);
            JS_FreeCString(handle->ctx, str);
        } else {
            result_str = strdup("Unknown JS Exception");
        }
        JS_FreeValue(handle->ctx, stack);
        JS_FreeValue(handle->ctx, exc);
    } else {
        const char *str = JS_ToCString(handle->ctx, val);
        if (str) {
            result_str = strdup(str);
            JS_FreeCString(handle->ctx, str);
        } else {
            result_str = strdup("undefined");
        }
    }
    JS_FreeValue(handle->ctx, val);

    return result_str;
}

QJS_EXPORT int qjs_dart_pump(QjsDartRuntime *handle) {
    if (!handle || !handle->rt) return 0;
    JSContext *pctx;
    int ret = JS_ExecutePendingJob(handle->rt, &pctx);
    return ret;
}

QJS_EXPORT void qjs_dart_free_string(char *str) {
    if (str) {
        free(str);
    }
}
