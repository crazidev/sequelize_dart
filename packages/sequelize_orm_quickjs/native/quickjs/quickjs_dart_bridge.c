#include "quickjs.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <sqlite3.h>

#if defined(_WIN32)
#define QJS_EXPORT __declspec(dllexport)
#include <windows.h>
#include <bcrypt.h>
#else
#define QJS_EXPORT __attribute__((visibility("default")))
#include <unistd.h>
#if defined(__APPLE__)
#include <stdlib.h>
#else
#include <sys/random.h>
#endif
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Cryptographic Primitives in Pure C (SHA-256, HMAC, PBKDF2)
// ─────────────────────────────────────────────────────────────────────────────

// SHA-256 Implementation
typedef struct {
    uint32_t state[8];
    uint64_t count;
    uint8_t buffer[64];
} QjsSha256Ctx;

#define SHA256_ROTR(a,b) (((a) >> (b)) | ((a) << (32 - (b))))
#define SHA256_CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define SHA256_MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define SHA256_EP0(x) (SHA256_ROTR(x,2) ^ SHA256_ROTR(x,13) ^ SHA256_ROTR(x,22))
#define SHA256_EP1(x) (SHA256_ROTR(x,6) ^ SHA256_ROTR(x,11) ^ SHA256_ROTR(x,25))
#define SHA256_SIG0(x) (SHA256_ROTR(x,7) ^ SHA256_ROTR(x,18) ^ ((x) >> 3))
#define SHA256_SIG1(x) (SHA256_ROTR(x,17) ^ SHA256_ROTR(x,19) ^ ((x) >> 10))

static const uint32_t K256[64] = {
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
};

static void qjs_sha256_transform(QjsSha256Ctx *ctx, const uint8_t data[64]) {
    uint32_t a, b, c, d, e, f, g, h, i, j, t1, t2, m[64];
    for (i = 0, j = 0; i < 16; ++i, j += 4)
        m[i] = ((uint32_t)data[j] << 24) | ((uint32_t)data[j + 1] << 16) |
               ((uint32_t)data[j + 2] << 8) | ((uint32_t)data[j + 3]);
    for (; i < 64; ++i)
        m[i] = SHA256_SIG1(m[i - 2]) + m[i - 7] + SHA256_SIG0(m[i - 15]) + m[i - 16];

    a = ctx->state[0]; b = ctx->state[1]; c = ctx->state[2]; d = ctx->state[3];
    e = ctx->state[4]; f = ctx->state[5]; g = ctx->state[6]; h = ctx->state[7];

    for (i = 0; i < 64; ++i) {
        t1 = h + SHA256_EP1(e) + SHA256_CH(e,f,g) + K256[i] + m[i];
        t2 = SHA256_EP0(a) + SHA256_MAJ(a,b,c);
        h = g; g = f; f = e; e = d + t1;
        d = c; c = b; b = a; a = t1 + t2;
    }
    ctx->state[0] += a; ctx->state[1] += b; ctx->state[2] += c; ctx->state[3] += d;
    ctx->state[4] += e; ctx->state[5] += f; ctx->state[6] += g; ctx->state[7] += h;
}

static void qjs_sha256_init(QjsSha256Ctx *ctx) {
    ctx->count = 0;
    ctx->state[0] = 0x6a09e667; ctx->state[1] = 0xbb67ae85;
    ctx->state[2] = 0x3c6ef372; ctx->state[3] = 0xa54ff53a;
    ctx->state[4] = 0x510e527f; ctx->state[5] = 0x9b05688c;
    ctx->state[6] = 0x1f83d9ab; ctx->state[7] = 0x5be0cd19;
}

static void qjs_sha256_update(QjsSha256Ctx *ctx, const uint8_t *data, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        ctx->buffer[(ctx->count++) & 63] = data[i];
        if ((ctx->count & 63) == 0)
            qjs_sha256_transform(ctx, ctx->buffer);
    }
}

static void qjs_sha256_final(QjsSha256Ctx *ctx, uint8_t hash[32]) {
    uint64_t i = ctx->count;
    qjs_sha256_update(ctx, (const uint8_t*)"\x80", 1);
    while ((ctx->count & 63) != 56)
        qjs_sha256_update(ctx, (const uint8_t*)"\0", 1);
    i *= 8;
    uint8_t len_bytes[8];
    for (int j = 0; j < 8; j++) len_bytes[7 - j] = (uint8_t)(i >> (j * 8));
    qjs_sha256_update(ctx, len_bytes, 8);
    for (i = 0; i < 8; ++i) {
        hash[i * 4]     = (uint8_t)(ctx->state[i] >> 24);
        hash[i * 4 + 1] = (uint8_t)(ctx->state[i] >> 16);
        hash[i * 4 + 2] = (uint8_t)(ctx->state[i] >> 8);
        hash[i * 4 + 3] = (uint8_t)(ctx->state[i]);
    }
}

// HMAC-SHA256 Implementation
static void qjs_hmac_sha256(const uint8_t *key, size_t key_len,
                            const uint8_t *data, size_t data_len,
                            uint8_t out[32]) {
    uint8_t k[64];
    memset(k, 0, sizeof(k));
    if (key_len > 64) {
        QjsSha256Ctx kctx;
        qjs_sha256_init(&kctx);
        qjs_sha256_update(&kctx, key, key_len);
        qjs_sha256_final(&kctx, k);
    } else {
        memcpy(k, key, key_len);
    }
    uint8_t ipad[64], opad[64];
    for (int i = 0; i < 64; i++) {
        ipad[i] = k[i] ^ 0x36;
        opad[i] = k[i] ^ 0x5c;
    }
    QjsSha256Ctx ictx;
    qjs_sha256_init(&ictx);
    qjs_sha256_update(&ictx, ipad, 64);
    qjs_sha256_update(&ictx, data, data_len);
    uint8_t inner_hash[32];
    qjs_sha256_final(&ictx, inner_hash);

    QjsSha256Ctx octx;
    qjs_sha256_init(&octx);
    qjs_sha256_update(&octx, opad, 64);
    qjs_sha256_update(&octx, inner_hash, 32);
    qjs_sha256_final(&octx, out);
}

// PBKDF2-HMAC-SHA256 Implementation
static void qjs_pbkdf2_hmac_sha256(const uint8_t *pass, size_t pass_len,
                                   const uint8_t *salt, size_t salt_len,
                                   uint32_t iterations, uint8_t *out, size_t out_len) {
    uint32_t block_count = (uint32_t)((out_len + 31) / 32);
    uint8_t u[32], t[32];
    uint8_t *salt_ext = (uint8_t*)malloc(salt_len + 4);
    if (!salt_ext) return;
    memcpy(salt_ext, salt, salt_len);

    for (uint32_t i = 1; i <= block_count; i++) {
        salt_ext[salt_len]     = (uint8_t)(i >> 24);
        salt_ext[salt_len + 1] = (uint8_t)(i >> 16);
        salt_ext[salt_len + 2] = (uint8_t)(i >> 8);
        salt_ext[salt_len + 3] = (uint8_t)(i);

        qjs_hmac_sha256(pass, pass_len, salt_ext, salt_len + 4, u);
        memcpy(t, u, 32);

        for (uint32_t c = 1; c < iterations; c++) {
            qjs_hmac_sha256(pass, pass_len, u, 32, u);
            for (int k = 0; k < 32; k++) t[k] ^= u[k];
        }

        size_t write_len = (i == block_count && (out_len % 32) != 0) ? (out_len % 32) : 32;
        memcpy(out + (i - 1) * 32, t, write_len);
    }
    free(salt_ext);
}

// Cryptographically secure random bytes
static void qjs_secure_random(uint8_t *buf, size_t len) {
#if defined(_WIN32)
    BCryptGenRandom(NULL, buf, (ULONG)len, BCRYPT_USE_SYSTEM_PREFERRED_RNG);
#elif defined(__APPLE__)
    arc4random_buf(buf, len);
#else
    if (getentropy(buf, len) != 0) {
        FILE *f = fopen("/dev/urandom", "rb");
        if (f) {
            fread(buf, 1, len, f);
            fclose(f);
        }
    }
#endif
}

// ─────────────────────────────────────────────────────────────────────────────
// SQLite PreparedStatement & Atom Cache
// ─────────────────────────────────────────────────────────────────────────────

#define MAX_SQLITE_DBS 32
#define STMT_CACHE_CAPACITY 64

typedef struct StmtCacheEntry {
    char *sql;
    sqlite3_stmt *stmt;
    int col_count;
    JSAtom *col_atoms;
    struct StmtCacheEntry *prev;
    struct StmtCacheEntry *next;
} StmtCacheEntry;

typedef struct {
    StmtCacheEntry *head;
    StmtCacheEntry *tail;
    int count;
} StmtCache;

typedef const char* (*DartBridgeCallback)(const char* name, const char* argsJson);

typedef struct QjsDartRuntime {
    JSRuntime *rt;
    JSContext *ctx;
    DartBridgeCallback callback;
    void *userdata;

    // Cached JS function values
    JSValue fn_handle_request;
    JSValue fn_trigger_timer;
    JSValue fn_socket_data;
    JSValue fn_socket_emit;

    // Per-runtime SQLite connections and statement caches
    sqlite3* sqlite_dbs[MAX_SQLITE_DBS];
    StmtCache stmt_caches[MAX_SQLITE_DBS];
} QjsDartRuntime;

static DartBridgeCallback g_dart_callback = NULL;

static void stmt_cache_init(StmtCache *cache) {
    cache->head = NULL;
    cache->tail = NULL;
    cache->count = 0;
}

static void stmt_cache_free_entry(JSContext *ctx, StmtCacheEntry *entry) {
    if (!entry) return;
    if (entry->stmt) sqlite3_finalize(entry->stmt);
    if (entry->col_atoms) {
        if (ctx) {
            for (int i = 0; i < entry->col_count; i++) {
                JS_FreeAtom(ctx, entry->col_atoms[i]);
            }
        }
        free(entry->col_atoms);
    }
    if (entry->sql) free(entry->sql);
    free(entry);
}

static void stmt_cache_clear(JSContext *ctx, StmtCache *cache) {
    StmtCacheEntry *curr = cache->head;
    while (curr) {
        StmtCacheEntry *next = curr->next;
        stmt_cache_free_entry(ctx, curr);
        curr = next;
    }
    cache->head = NULL;
    cache->tail = NULL;
    cache->count = 0;
}

static StmtCacheEntry* stmt_cache_lookup_and_touch(StmtCache *cache, const char *sql) {
    StmtCacheEntry *curr = cache->head;
    while (curr) {
        if (strcmp(curr->sql, sql) == 0) {
            // Move to head (MRU)
            if (curr != cache->head) {
                if (curr->prev) curr->prev->next = curr->next;
                if (curr->next) curr->next->prev = curr->prev;
                if (curr == cache->tail) cache->tail = curr->prev;
                curr->prev = NULL;
                curr->next = cache->head;
                if (cache->head) cache->head->prev = curr;
                cache->head = curr;
            }
            return curr;
        }
        curr = curr->next;
    }
    return NULL;
}

static void stmt_cache_insert(JSContext *ctx, StmtCache *cache, const char *sql,
                              sqlite3_stmt *stmt, int col_count, JSAtom *atoms) {
    // If full, evict tail (LRU)
    if (cache->count >= STMT_CACHE_CAPACITY && cache->tail) {
        StmtCacheEntry *evict = cache->tail;
        if (evict->prev) evict->prev->next = NULL;
        cache->tail = evict->prev;
        if (cache->head == evict) cache->head = NULL;
        stmt_cache_free_entry(ctx, evict);
        cache->count--;
    }

    StmtCacheEntry *entry = (StmtCacheEntry*)malloc(sizeof(StmtCacheEntry));
    if (!entry) return;
    entry->sql = strdup(sql);
    entry->stmt = stmt;
    entry->col_count = col_count;
    entry->col_atoms = atoms;
    entry->prev = NULL;
    entry->next = cache->head;
    if (cache->head) cache->head->prev = entry;
    cache->head = entry;
    if (!cache->tail) cache->tail = entry;
    cache->count++;
}

// ─────────────────────────────────────────────────────────────────────────────
// Native SQLite Bindings with Statement Caching & Atom Reuse
// ─────────────────────────────────────────────────────────────────────────────

static int sqlite_find_free_slot(QjsDartRuntime *rt) {
    for (int i = 0; i < MAX_SQLITE_DBS; i++) {
        if (!rt->sqlite_dbs[i]) return i;
    }
    return -1;
}

static JSValue js_sqlite_open(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_EXCEPTION;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    if (!rt) return JS_ThrowInternalError(ctx, "No runtime associated with context");

    const char *path = JS_ToCString(ctx, argv[0]);
    if (!path) return JS_EXCEPTION;

    int slot = sqlite_find_free_slot(rt);
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

    rt->sqlite_dbs[slot] = db;
    stmt_cache_init(&rt->stmt_caches[slot]);
    return JS_NewInt32(ctx, slot);
}

static JSValue js_sqlite_close(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_UNDEFINED;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    if (!rt) return JS_UNDEFINED;

    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot >= 0 && slot < MAX_SQLITE_DBS && rt->sqlite_dbs[slot]) {
        stmt_cache_clear(ctx, &rt->stmt_caches[slot]);
        sqlite3_close(rt->sqlite_dbs[slot]);
        rt->sqlite_dbs[slot] = NULL;
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

static StmtCacheEntry* sqlite_get_cached_stmt(QjsDartRuntime *rt, int slot, const char *sql, sqlite3_stmt **out_stmt) {
    StmtCache *cache = &rt->stmt_caches[slot];
    StmtCacheEntry *entry = stmt_cache_lookup_and_touch(cache, sql);
    if (entry) {
        sqlite3_reset(entry->stmt);
        sqlite3_clear_bindings(entry->stmt);
        *out_stmt = entry->stmt;
        return entry;
    }
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(rt->sqlite_dbs[slot], sql, -1, &stmt, NULL);
    if (rc != SQLITE_OK) {
        *out_stmt = NULL;
        return NULL;
    }
    int col_count = sqlite3_column_count(stmt);
    JSAtom *atoms = NULL;
    if (col_count > 0) {
        atoms = (JSAtom*)malloc(sizeof(JSAtom) * col_count);
        for (int i = 0; i < col_count; i++) {
            atoms[i] = JS_NewAtom(rt->ctx, sqlite3_column_name(stmt, i));
        }
    }
    stmt_cache_insert(rt->ctx, cache, sql, stmt, col_count, atoms);
    *out_stmt = stmt;
    return cache->head;
}

static JSValue js_sqlite_query(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    if (!rt) return JS_ThrowInternalError(ctx, "No runtime");

    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !rt->sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    sqlite3_stmt *stmt = NULL;
    StmtCacheEntry *cached = sqlite_get_cached_stmt(rt, slot, sql, &stmt);
    JS_FreeCString(ctx, sql);

    if (!stmt) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(rt->sqlite_dbs[slot]));
    }

    if (argc >= 3) {
        sqlite_bind_all_params(stmt, ctx, argv[2]);
    }

    JSValue rows = JS_NewArray(ctx);
    int col_count = cached ? cached->col_count : sqlite3_column_count(stmt);
    JSAtom *col_atoms = cached ? cached->col_atoms : NULL;
    uint32_t row_idx = 0;
    int rc;

    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        JSValue row = JS_NewObject(ctx);
        for (int i = 0; i < col_count; i++) {
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
            if (col_atoms) {
                JS_SetProperty(ctx, row, col_atoms[i], val);
            } else {
                JS_SetPropertyStr(ctx, row, sqlite3_column_name(stmt, i), val);
            }
        }
        JS_SetPropertyUint32(ctx, rows, row_idx++, row);
    }

    if (!cached) sqlite3_finalize(stmt);

    if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
        JS_FreeValue(ctx, rows);
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(rt->sqlite_dbs[slot]));
    }

    return rows;
}

// Single-row fast query
static JSValue js_sqlite_get(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    if (!rt) return JS_ThrowInternalError(ctx, "No runtime");

    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !rt->sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    sqlite3_stmt *stmt = NULL;
    StmtCacheEntry *cached = sqlite_get_cached_stmt(rt, slot, sql, &stmt);
    JS_FreeCString(ctx, sql);

    if (!stmt) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(rt->sqlite_dbs[slot]));
    }

    if (argc >= 3) {
        sqlite_bind_all_params(stmt, ctx, argv[2]);
    }

    int rc = sqlite3_step(stmt);
    JSValue row = JS_NULL;

    if (rc == SQLITE_ROW) {
        row = JS_NewObject(ctx);
        int col_count = cached ? cached->col_count : sqlite3_column_count(stmt);
        JSAtom *col_atoms = cached ? cached->col_atoms : NULL;
        for (int i = 0; i < col_count; i++) {
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
            if (col_atoms) {
                JS_SetProperty(ctx, row, col_atoms[i], val);
            } else {
                JS_SetPropertyStr(ctx, row, sqlite3_column_name(stmt, i), val);
            }
        }
    }

    if (!cached) sqlite3_finalize(stmt);

    if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
        JS_FreeValue(ctx, row);
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(rt->sqlite_dbs[slot]));
    }

    return row;
}

static JSValue js_sqlite_run(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    if (!rt) return JS_ThrowInternalError(ctx, "No runtime");

    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !rt->sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    sqlite3_stmt *stmt = NULL;
    StmtCacheEntry *cached = sqlite_get_cached_stmt(rt, slot, sql, &stmt);
    JS_FreeCString(ctx, sql);

    if (!stmt) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(rt->sqlite_dbs[slot]));
    }

    if (argc >= 3) {
        sqlite_bind_all_params(stmt, ctx, argv[2]);
    }

    int rc = sqlite3_step(stmt);
    sqlite3 *db = rt->sqlite_dbs[slot];
    int64_t last_id = sqlite3_last_insert_rowid(db);
    int changes = sqlite3_changes(db);

    if (!cached) sqlite3_finalize(stmt);

    if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
        return JS_ThrowInternalError(ctx, "%s", sqlite3_errmsg(db));
    }

    JSValue res = JS_NewObject(ctx);
    JS_SetPropertyStr(ctx, res, "lastID", JS_NewInt64(ctx, last_id));
    JS_SetPropertyStr(ctx, res, "changes", JS_NewInt32(ctx, changes));
    return res;
}

static JSValue js_sqlite_exec(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    if (!rt) return JS_ThrowInternalError(ctx, "No runtime");

    int32_t slot = -1;
    JS_ToInt32(ctx, &slot, argv[0]);
    if (slot < 0 || slot >= MAX_SQLITE_DBS || !rt->sqlite_dbs[slot]) {
        return JS_ThrowInternalError(ctx, "Invalid SQLite database handle");
    }

    const char *sql = JS_ToCString(ctx, argv[1]);
    if (!sql) return JS_EXCEPTION;

    char *err_msg = NULL;
    int rc = sqlite3_exec(rt->sqlite_dbs[slot], sql, NULL, NULL, &err_msg);
    JS_FreeCString(ctx, sql);

    if (rc != SQLITE_OK) {
        JSValue err = JS_ThrowInternalError(ctx, "%s", err_msg ? err_msg : "SQLite exec error");
        if (err_msg) sqlite3_free(err_msg);
        return err;
    }
    return JS_UNDEFINED;
}

// ─────────────────────────────────────────────────────────────────────────────
// Native Crypto in C (Zero FFI Dart Hops)
// ─────────────────────────────────────────────────────────────────────────────

static JSValue js_crypto_random_bytes(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_EXCEPTION;
    int32_t size = 0;
    JS_ToInt32(ctx, &size, argv[0]);
    if (size <= 0) size = 0;

    uint8_t *buf = (uint8_t*)malloc(size);
    if (size > 0 && buf) {
        qjs_secure_random(buf, (size_t)size);
    }
    JSValue ab = JS_NewArrayBuffer(ctx, buf, size, NULL, NULL, 0);
    // Return Uint8Array view if Uint8Array constructor is present
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue u8_ctor = JS_GetPropertyStr(ctx, global, "Uint8Array");
    JSValue res = ab;
    if (JS_IsFunction(ctx, u8_ctor)) {
        JSValue args[1] = { ab };
        res = JS_CallConstructor(ctx, u8_ctor, 1, args);
        JS_FreeValue(ctx, ab);
    }
    JS_FreeValue(ctx, u8_ctor);
    JS_FreeValue(ctx, global);
    return res;
}

// Helper to extract bytes from string, Uint8Array or ArrayBuffer
static uint8_t* js_get_bytes(JSContext *ctx, JSValueConst val, size_t *out_len) {
    size_t len = 0;
    uint8_t *data = JS_GetArrayBuffer(ctx, &len, val);
    if (data) {
        *out_len = len;
        uint8_t *copy = (uint8_t*)malloc(len);
        if (copy) memcpy(copy, data, len);
        return copy;
    }
    // Check for typed array (.buffer + byteOffset + byteLength)
    JSValue buffer_prop = JS_GetPropertyStr(ctx, val, "buffer");
    if (!JS_IsUndefined(buffer_prop)) {
        size_t ab_len = 0;
        uint8_t *ab_data = JS_GetArrayBuffer(ctx, &ab_len, buffer_prop);
        int32_t offset = 0, byte_len = 0;
        JSValue v_off = JS_GetPropertyStr(ctx, val, "byteOffset");
        JSValue v_len = JS_GetPropertyStr(ctx, val, "byteLength");
        JS_ToInt32(ctx, &offset, v_off);
        JS_ToInt32(ctx, &byte_len, v_len);
        JS_FreeValue(ctx, v_off);
        JS_FreeValue(ctx, v_len);
        JS_FreeValue(ctx, buffer_prop);
        if (ab_data && byte_len >= 0 && offset + byte_len <= (int32_t)ab_len) {
            *out_len = (size_t)byte_len;
            uint8_t *copy = (uint8_t*)malloc(byte_len);
            if (copy) memcpy(copy, ab_data + offset, byte_len);
            return copy;
        }
    }
    JS_FreeValue(ctx, buffer_prop);

    // Fallback: UTF-8 string
    const char *str = JS_ToCStringLen(ctx, &len, val);
    if (str) {
        *out_len = len;
        uint8_t *copy = (uint8_t*)malloc(len);
        if (copy) memcpy(copy, str, len);
        JS_FreeCString(ctx, str);
        return copy;
    }
    *out_len = 0;
    return NULL;
}

static JSValue js_crypto_sha256_digest(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 1) return JS_EXCEPTION;
    size_t data_len = 0;
    uint8_t *data = js_get_bytes(ctx, argv[0], &data_len);
    if (!data && data_len > 0) return JS_EXCEPTION;

    QjsSha256Ctx sctx;
    qjs_sha256_init(&sctx);
    if (data && data_len > 0) {
        qjs_sha256_update(&sctx, data, data_len);
        free(data);
    }
    uint8_t hash[32];
    qjs_sha256_final(&sctx, hash);

    const char *encoding = "hex";
    if (argc >= 2) {
        const char *enc = JS_ToCString(ctx, argv[1]);
        if (enc) {
            if (strcmp(enc, "base64") == 0) encoding = "base64";
            JS_FreeCString(ctx, enc);
        }
    }

    if (strcmp(encoding, "hex") == 0) {
        char hex[65];
        for (int i = 0; i < 32; i++) snprintf(hex + i * 2, 3, "%02x", hash[i]);
        hex[64] = '\0';
        return JS_NewString(ctx, hex);
    }

    return JS_NewArrayBufferCopy(ctx, hash, 32);
}

static JSValue js_crypto_hmac_sha256(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_EXCEPTION;
    size_t key_len = 0, data_len = 0;
    uint8_t *key = js_get_bytes(ctx, argv[0], &key_len);
    uint8_t *data = js_get_bytes(ctx, argv[1], &data_len);

    uint8_t out[32];
    qjs_hmac_sha256(key ? key : (const uint8_t*)"", key_len,
                    data ? data : (const uint8_t*)"", data_len, out);

    if (key) free(key);
    if (data) free(data);

    return JS_NewArrayBufferCopy(ctx, out, 32);
}

static JSValue js_crypto_pbkdf2_sync(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 4) return JS_EXCEPTION;
    size_t pass_len = 0, salt_len = 0;
    uint8_t *pass = js_get_bytes(ctx, argv[0], &pass_len);
    uint8_t *salt = js_get_bytes(ctx, argv[1], &salt_len);

    int32_t iterations = 4096, keylen = 32;
    JS_ToInt32(ctx, &iterations, argv[2]);
    JS_ToInt32(ctx, &keylen, argv[3]);
    if (iterations < 1) iterations = 1;
    if (keylen < 1) keylen = 32;

    uint8_t *out = (uint8_t*)malloc(keylen);
    if (!out) {
        if (pass) free(pass);
        if (salt) free(salt);
        return JS_EXCEPTION;
    }

    qjs_pbkdf2_hmac_sha256(pass ? pass : (const uint8_t*)"", pass_len,
                           salt ? salt : (const uint8_t*)"", salt_len,
                           (uint32_t)iterations, out, (size_t)keylen);

    if (pass) free(pass);
    if (salt) free(salt);

    return JS_NewArrayBuffer(ctx, out, keylen, NULL, NULL, 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Bridge Notification & Callbacks
// ─────────────────────────────────────────────────────────────────────────────

static JSValue js_ffi_notify(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv) {
    if (argc < 2) return JS_UNDEFINED;
    QjsDartRuntime *rt = (QjsDartRuntime*)JS_GetContextOpaque(ctx);
    DartBridgeCallback cb = (rt && rt->callback) ? rt->callback : g_dart_callback;
    if (!cb) return JS_UNDEFINED;

    const char *name = JS_ToCString(ctx, argv[0]);
    const char *args = JS_ToCString(ctx, argv[1]);
    if (!name || !args) {
        if (name) JS_FreeCString(ctx, name);
        if (args) JS_FreeCString(ctx, args);
        return JS_UNDEFINED;
    }

    const char *res = cb(name, args);
    JS_FreeCString(ctx, name);
    JS_FreeCString(ctx, args);

    if (res) {
        JSValue val = JS_NewString(ctx, res);
        free((void*)res);
        return val;
    }
    return JS_UNDEFINED;
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

// ─────────────────────────────────────────────────────────────────────────────
// Public Exported C APIs
// ─────────────────────────────────────────────────────────────────────────────

QJS_EXPORT void qjs_dart_set_callback(DartBridgeCallback cb) {
    g_dart_callback = cb;
}

QJS_EXPORT void qjs_dart_set_runtime_callback(QjsDartRuntime *handle, DartBridgeCallback cb) {
    if (handle) handle->callback = cb;
}

QJS_EXPORT QjsDartRuntime* qjs_dart_create_runtime(void) {
    QjsDartRuntime *handle = (QjsDartRuntime*)calloc(1, sizeof(QjsDartRuntime));
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

    JS_SetContextOpaque(handle->ctx, handle);

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
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "all", JS_NewCFunction(handle->ctx, js_sqlite_query, "all", 3));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "get", JS_NewCFunction(handle->ctx, js_sqlite_get, "get", 3));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "run", JS_NewCFunction(handle->ctx, js_sqlite_run, "run", 3));
    JS_SetPropertyStr(handle->ctx, sqlite_obj, "exec", JS_NewCFunction(handle->ctx, js_sqlite_exec, "exec", 2));
    JS_SetPropertyStr(handle->ctx, global, "_native_sqlite", sqlite_obj);

    // Register native C Crypto
    JSValue crypto_obj = JS_NewObject(handle->ctx);
    JS_SetPropertyStr(handle->ctx, crypto_obj, "randomBytes", JS_NewCFunction(handle->ctx, js_crypto_random_bytes, "randomBytes", 1));
    JS_SetPropertyStr(handle->ctx, crypto_obj, "sha256Digest", JS_NewCFunction(handle->ctx, js_crypto_sha256_digest, "sha256Digest", 2));
    JS_SetPropertyStr(handle->ctx, crypto_obj, "hmacSha256", JS_NewCFunction(handle->ctx, js_crypto_hmac_sha256, "hmacSha256", 2));
    JS_SetPropertyStr(handle->ctx, crypto_obj, "pbkdf2Sync", JS_NewCFunction(handle->ctx, js_crypto_pbkdf2_sync, "pbkdf2Sync", 4));
    JS_SetPropertyStr(handle->ctx, global, "_native_crypto", crypto_obj);

    // Register console.log
    JSValue console = JS_NewObject(handle->ctx);
    JS_SetPropertyStr(handle->ctx, console, "log", JS_NewCFunction(handle->ctx, js_print, "log", 1));
    JS_SetPropertyStr(handle->ctx, console, "info", JS_NewCFunction(handle->ctx, js_print, "info", 1));
    JS_SetPropertyStr(handle->ctx, console, "warn", JS_NewCFunction(handle->ctx, js_print, "warn", 1));
    JS_SetPropertyStr(handle->ctx, console, "error", JS_NewCFunction(handle->ctx, js_print, "error", 1));
    JS_SetPropertyStr(handle->ctx, global, "console", console);

    JS_FreeValue(handle->ctx, global);

    handle->fn_handle_request = JS_UNDEFINED;
    handle->fn_trigger_timer = JS_UNDEFINED;
    handle->fn_socket_data = JS_UNDEFINED;
    handle->fn_socket_emit = JS_UNDEFINED;

    return handle;
}

QJS_EXPORT void qjs_dart_free_runtime(QjsDartRuntime *handle) {
    if (!handle) return;
    if (handle->ctx) {
        for (int i = 0; i < MAX_SQLITE_DBS; i++) {
            if (handle->sqlite_dbs[i]) {
                stmt_cache_clear(handle->ctx, &handle->stmt_caches[i]);
                sqlite3_close(handle->sqlite_dbs[i]);
                handle->sqlite_dbs[i] = NULL;
            }
        }
        JS_FreeValue(handle->ctx, handle->fn_handle_request);
        JS_FreeValue(handle->ctx, handle->fn_trigger_timer);
        JS_FreeValue(handle->ctx, handle->fn_socket_data);
        JS_FreeValue(handle->ctx, handle->fn_socket_emit);
        JS_FreeContext(handle->ctx);
    }
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

// Direct function call API (No JS parsing/eval)
QJS_EXPORT int qjs_dart_call_async(QjsDartRuntime *handle, int promise_id, const char *json_args) {
    if (!handle || !handle->ctx || !json_args) return -1;
    JSContext *ctx = handle->ctx;

    JSValue global = JS_GetGlobalObject(ctx);
    JSValue fn = JS_GetPropertyStr(ctx, global, "_dart_handleRequest");
    if (!JS_IsFunction(ctx, fn)) {
        JS_FreeValue(ctx, fn);
        JS_FreeValue(ctx, global);
        return -2;
    }

    JSValue parsed_args = JS_ParseJSON(ctx, json_args, strlen(json_args), "<args>");
    if (JS_IsException(parsed_args)) {
        JS_FreeValue(ctx, fn);
        JS_FreeValue(ctx, global);
        return -3;
    }

    JSValue promise_id_val = JS_NewInt32(ctx, promise_id);
    JSValue argv[2] = { promise_id_val, parsed_args };
    JSValue ret = JS_Call(ctx, fn, global, 2, argv);

    JS_FreeValue(ctx, promise_id_val);
    JS_FreeValue(ctx, parsed_args);
    JS_FreeValue(ctx, fn);
    JS_FreeValue(ctx, global);

    if (JS_IsException(ret)) {
        JSValue exc = JS_GetException(ctx);
        JS_FreeValue(ctx, exc);
        JS_FreeValue(ctx, ret);
        return -4;
    }
    JS_FreeValue(ctx, ret);
    return 0;
}

// Native trigger timer direct call
QJS_EXPORT int qjs_dart_trigger_timer(QjsDartRuntime *handle, int timer_id) {
    if (!handle || !handle->ctx) return -1;
    JSContext *ctx = handle->ctx;
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue fn = JS_GetPropertyStr(ctx, global, "_dart_trigger_timer");
    if (JS_IsFunction(ctx, fn)) {
        JSValue arg = JS_NewInt32(ctx, timer_id);
        JSValue ret = JS_Call(ctx, fn, global, 1, &arg);
        JS_FreeValue(ctx, arg);
        JS_FreeValue(ctx, ret);
    }
    JS_FreeValue(ctx, fn);
    JS_FreeValue(ctx, global);
    return 0;
}

// Native socket data direct call (Zero-copy / ArrayBuffer transport)
QJS_EXPORT int qjs_dart_emit_socket_data(QjsDartRuntime *handle, int socket_id, const uint8_t *bytes, size_t len) {
    if (!handle || !handle->ctx) return -1;
    JSContext *ctx = handle->ctx;
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue fn = JS_GetPropertyStr(ctx, global, "_dart_socket_data");
    if (JS_IsFunction(ctx, fn)) {
        JSValue id_val = JS_NewInt32(ctx, socket_id);
        JSValue ab = JS_NewArrayBufferCopy(ctx, bytes, len);
        JSValue argv[2] = { id_val, ab };
        JSValue ret = JS_Call(ctx, fn, global, 2, argv);
        JS_FreeValue(ctx, id_val);
        JS_FreeValue(ctx, ab);
        JS_FreeValue(ctx, ret);
    }
    JS_FreeValue(ctx, fn);
    JS_FreeValue(ctx, global);
    return 0;
}

// Native socket event direct call
QJS_EXPORT int qjs_dart_emit_socket_event(QjsDartRuntime *handle, int socket_id, const char *event_name) {
    if (!handle || !handle->ctx || !event_name) return -1;
    JSContext *ctx = handle->ctx;
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue fn = JS_GetPropertyStr(ctx, global, "_dart_emit_socket");
    if (JS_IsFunction(ctx, fn)) {
        JSValue id_val = JS_NewInt32(ctx, socket_id);
        JSValue ev_val = JS_NewString(ctx, event_name);
        JSValue argv[2] = { id_val, ev_val };
        JSValue ret = JS_Call(ctx, fn, global, 2, argv);
        JS_FreeValue(ctx, id_val);
        JS_FreeValue(ctx, ev_val);
        JS_FreeValue(ctx, ret);
    }
    JS_FreeValue(ctx, fn);
    JS_FreeValue(ctx, global);
    return 0;
}

// Native socket error direct call
QJS_EXPORT int qjs_dart_emit_socket_error(QjsDartRuntime *handle, int socket_id, const char *error_msg) {
    if (!handle || !handle->ctx) return -1;
    JSContext *ctx = handle->ctx;
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue fn = JS_GetPropertyStr(ctx, global, "_dart_emit_socket");
    if (JS_IsFunction(ctx, fn)) {
        JSValue id_val = JS_NewInt32(ctx, socket_id);
        JSValue ev_val = JS_NewString(ctx, "error");
        JSValue err_ctor = JS_GetPropertyStr(ctx, global, "Error");
        JSValue msg_val = JS_NewString(ctx, error_msg ? error_msg : "Socket error");
        JSValue err_obj = JS_CallConstructor(ctx, err_ctor, 1, &msg_val);
        JS_FreeValue(ctx, err_ctor);
        JS_FreeValue(ctx, msg_val);

        JSValue argv[3] = { id_val, ev_val, err_obj };
        JSValue ret = JS_Call(ctx, fn, global, 3, argv);
        JS_FreeValue(ctx, id_val);
        JS_FreeValue(ctx, ev_val);
        JS_FreeValue(ctx, err_obj);
        JS_FreeValue(ctx, ret);
    }
    JS_FreeValue(ctx, fn);
    JS_FreeValue(ctx, global);
    return 0;
}

// Single FFI-crossing pump_all
QJS_EXPORT int qjs_dart_pump_all(QjsDartRuntime *handle) {
    if (!handle || !handle->rt) return 0;
    JSContext *pctx;
    int count = 0;
    int ret;
    while ((ret = JS_ExecutePendingJob(handle->rt, &pctx)) > 0) {
        count++;
    }
    return (ret < 0) ? -count : count;
}

QJS_EXPORT int qjs_dart_pump(QjsDartRuntime *handle) {
    if (!handle || !handle->rt) return 0;
    JSContext *pctx;
    return JS_ExecutePendingJob(handle->rt, &pctx);
}

QJS_EXPORT void qjs_dart_set_memory_limit(QjsDartRuntime *handle, size_t limit) {
    if (handle && handle->rt) JS_SetMemoryLimit(handle->rt, limit);
}

QJS_EXPORT void qjs_dart_set_gc_threshold(QjsDartRuntime *handle, size_t threshold) {
    if (handle && handle->rt) JS_SetGCThreshold(handle->rt, threshold);
}

QJS_EXPORT void qjs_dart_run_gc(QjsDartRuntime *handle) {
    if (handle && handle->rt) JS_RunGC(handle->rt);
}

QJS_EXPORT void qjs_dart_free_string(char *str) {
    if (str) {
        free(str);
    }
}
