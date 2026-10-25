#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "sqlite3.h"

static sqlite3 *sqliteraw_db;
static sqlite3_stmt *sqliteraw_stmt;

#define SQLITERAW_SQL_BUFFER_SIZE 8192
static char sqliteraw_sql_buffer[SQLITERAW_SQL_BUFFER_SIZE];
static int sqliteraw_sql_length;

void sqliteraw_sql_clear(void) {
  sqliteraw_sql_length = 0;
  sqliteraw_sql_buffer[0] = '\0';
}

void sqliteraw_sql_append_byte(int byte) {
  if (sqliteraw_sql_length + 1 >= SQLITERAW_SQL_BUFFER_SIZE) {
    return;
  }
  sqliteraw_sql_buffer[sqliteraw_sql_length++] = (char)byte;
  sqliteraw_sql_buffer[sqliteraw_sql_length] = '\0';
}

int sqliteraw_exec_buffered(void) {
  return sqlite3_exec(sqliteraw_db, sqliteraw_sql_buffer, 0, 0, 0);
}

int sqliteraw_prepare_buffered(void) {
  sqliteraw_stmt = 0;
  return sqlite3_prepare_v2(sqliteraw_db, sqliteraw_sql_buffer, -1, &sqliteraw_stmt, 0);
}

void sqliteraw_memory_write_i32(int offset, int value) {
  *(volatile int *)(intptr_t)offset = value;
}

int sqliteraw_memory_read(int offset) {
  return (int)*(volatile unsigned char *)(intptr_t)offset;
}

void sqliteraw_memory_write(int offset, int value) {
  *(volatile unsigned char *)(intptr_t)offset = (unsigned char)value;
}

int sqliteraw_memory_read_i32(int offset) {
  return *(volatile int *)(intptr_t)offset;
}

int sqliteraw_open_memdb(int database_out) {
  sqlite3 *db = 0;
  int rc = sqlite3_open_v2(
      "file:sqliteraw?mode=memory&vfs=memdb", &db,
      SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_URI, 0);
  sqliteraw_db = db;
  if (database_out != 0) {
    *(sqlite3 **)database_out = db;
  }
  return rc;
}

int sqliteraw_db_handle(void) { return (int)(intptr_t)sqliteraw_db; }

int sqliteraw_changes(void) { return sqlite3_changes(sqliteraw_db); }

const unsigned char *sqliteraw_errmsg_ptr(void) {
  return (const unsigned char *)sqlite3_errmsg(sqliteraw_db);
}

int sqliteraw_step(void) { return sqlite3_step(sqliteraw_stmt); }

int sqliteraw_column_int(int index) {
  return sqlite3_column_int(sqliteraw_stmt, index);
}

const unsigned char *sqliteraw_column_text_ptr(int index) {
  return (const unsigned char *)sqlite3_column_text(sqliteraw_stmt, index);
}

int sqliteraw_finalize(void) {
  int rc = sqlite3_finalize(sqliteraw_stmt);
  sqliteraw_stmt = 0;
  return rc;
}

int sqliteraw_close(void) {
  int rc = sqlite3_close(sqliteraw_db);
  sqliteraw_db = 0;
  sqliteraw_stmt = 0;
  return rc;
}

extern unsigned char __heap_base;

static unsigned char *heap_end;

static int ensure_heap_capacity(unsigned char *required_end) {
  uintptr_t current_end = (uintptr_t)__builtin_wasm_memory_size(0) * 65536u;
  uintptr_t needed_end = (uintptr_t)required_end;
  if (needed_end <= current_end) {
    return 1;
  }
  uintptr_t delta = needed_end - current_end;
  uintptr_t pages = (delta + 65535u) / 65536u;
  if (__builtin_wasm_memory_grow(0, (int)pages) == (unsigned int)-1) {
    return 0;
  }
  return 1;
}

void *malloc(size_t size) {
  if (heap_end == 0) {
    heap_end = &__heap_base;
  }
  size_t aligned = (size + 7u) & ~((size_t)7u);
  if (aligned == 0) {
    aligned = 8u;
  }
  unsigned char *result = heap_end;
  unsigned char *new_end = heap_end + aligned;
  if (!ensure_heap_capacity(new_end)) {
    return 0;
  }
  heap_end = new_end;
  return result;
}

void free(void *pointer) { (void)pointer; }

void *realloc(void *pointer, size_t size) {
  if (pointer == 0) {
    return malloc(size);
  }
  void *new_pointer = malloc(size);
  if (new_pointer == 0) {
    return 0;
  }
  memcpy(new_pointer, pointer, size);
  return new_pointer;
}

void *memcpy(void *dest, const void *src, size_t n) {
  unsigned char *d = (unsigned char *)dest;
  unsigned char const *s = (unsigned char const *)src;
  for (size_t i = 0; i < n; i++) {
    d[i] = s[i];
  }
  return dest;
}

void *memmove(void *dest, const void *src, size_t n) {
  unsigned char *d = (unsigned char *)dest;
  unsigned char const *s = (unsigned char const *)src;
  if (d == s || n == 0) {
    return dest;
  }
  if (d < s) {
    for (size_t i = 0; i < n; i++) {
      d[i] = s[i];
    }
  } else {
    for (size_t i = n; i > 0; i--) {
      d[i - 1] = s[i - 1];
    }
  }
  return dest;
}

void *memset(void *s, int c, size_t n) {
  unsigned char *p = (unsigned char *)s;
  unsigned char value = (unsigned char)c;
  for (size_t i = 0; i < n; i++) {
    p[i] = value;
  }
  return s;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  unsigned char const *a = (unsigned char const *)s1;
  unsigned char const *b = (unsigned char const *)s2;
  for (size_t i = 0; i < n; i++) {
    if (a[i] != b[i]) {
      return (int)a[i] - (int)b[i];
    }
  }
  return 0;
}

void *memchr(const void *s, int c, size_t n) {
  unsigned char const *p = (unsigned char const *)s;
  unsigned char value = (unsigned char)c;
  for (size_t i = 0; i < n; i++) {
    if (p[i] == value) {
      return (void *)(p + i);
    }
  }
  return 0;
}

size_t strlen(const char *s) {
  size_t n = 0;
  while (s[n] != '\0') {
    n++;
  }
  return n;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 != '\0' && *s1 == *s2) {
    s1++;
    s2++;
  }
  return (unsigned char)*s1 - (unsigned char)*s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  for (size_t i = 0; i < n; i++) {
    unsigned char left = (unsigned char)s1[i];
    unsigned char right = (unsigned char)s2[i];
    if (left != right) {
      return (int)left - (int)right;
    }
    if (left == '\0') {
      return 0;
    }
  }
  return 0;
}

char *strchr(const char *s, int c) {
  char value = (char)c;
  while (*s != '\0') {
    if (*s == value) {
      return (char *)s;
    }
    s++;
  }
  return value == '\0' ? (char *)s : 0;
}

char *strrchr(const char *s, int c) {
  char value = (char)c;
  char *last = 0;
  while (*s != '\0') {
    if (*s == value) {
      last = (char *)s;
    }
    s++;
  }
  if (value == '\0') {
    return (char *)s;
  }
  return last;
}

size_t strcspn(const char *s, const char *reject) {
  size_t count = 0;
  while (s[count] != '\0') {
    const char *r = reject;
    while (*r != '\0') {
      if (s[count] == *r) {
        return count;
      }
      r++;
    }
    count++;
  }
  return count;
}

size_t strspn(const char *s, const char *accept) {
  size_t count = 0;
  while (s[count] != '\0') {
    const char *a = accept;
    int found = 0;
    while (*a != '\0') {
      if (s[count] == *a) {
        found = 1;
        break;
      }
      a++;
    }
    if (!found) {
      return count;
    }
    count++;
  }
  return count;
}

double log(double x) {
  if (x <= 0.0) {
    return -1.0 / 0.0;
  }
  double y = 0.0;
  while (x >= 2.0) {
    x *= 0.5;
    y += 0.6931471805599453;
  }
  while (x < 1.0) {
    x *= 2.0;
    y -= 0.6931471805599453;
  }
  double z = (x - 1.0) / (x + 1.0);
  double z2 = z * z;
  double term = z;
  double sum = term;
  for (int i = 1; i < 12; i++) {
    term *= z2;
    sum += term / (2 * i + 1);
  }
  return y + 2.0 * sum;
}

double fabs(double x) {
  return x < 0.0 ? -x : x;
}

void qsort(void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *)) {
  if (nmemb < 2 || size == 0) {
    return;
  }

  unsigned char *bytes = (unsigned char *)base;
  unsigned char *tmp = (unsigned char *)malloc(size);
  if (tmp == 0) {
    return;
  }

  for (size_t i = 1; i < nmemb; i++) {
    memcpy(tmp, bytes + i * size, size);
    size_t j = i;
    while (j > 0) {
      int cmp = compar(bytes + (j - 1) * size, tmp);
      if (cmp <= 0) {
        break;
      }
      memcpy(bytes + j * size, bytes + (j - 1) * size, size);
      j--;
    }
    memcpy(bytes + j * size, tmp, size);
  }

  free(tmp);
}

FILE stdin_file;
FILE stdout_file;
FILE stderr_file;
FILE *stdin = &stdin_file;
FILE *stdout = &stdout_file;
FILE *stderr = &stderr_file;

static int sqliterawFormatString(char *str, size_t size, const char *format, va_list ap) {
  (void)format;
  (void)ap;
  if (size > 0) {
    str[0] = '\0';
  }
  return 0;
}

int vsnprintf(char *str, size_t size, const char *format, va_list ap) {
  return sqliterawFormatString(str, size, format, ap);
}

int snprintf(char *str, size_t size, const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  int result = vsnprintf(str, size, format, ap);
  va_end(ap);
  return result;
}

int fprintf(FILE *stream, const char *format, ...) {
  (void)stream;
  (void)format;
  return 0;
}

int printf(const char *format, ...) {
  (void)format;
  return 0;
}

int fflush(FILE *stream) {
  (void)stream;
  return 0;
}

typedef struct WebStubFile {
  sqlite3_io_methods const *pMethods;
} WebStubFile;

static int webStubClose(sqlite3_file *pFile) {
  (void)pFile;
  return SQLITE_OK;
}

static int webStubRead(sqlite3_file *pFile, void *zBuf, int iAmt, sqlite3_int64 iOfst) {
  (void)pFile;
  (void)zBuf;
  (void)iAmt;
  (void)iOfst;
  return SQLITE_IOERR_READ;
}

static int webStubWrite(sqlite3_file *pFile, const void *zBuf, int iAmt,
                        sqlite3_int64 iOfst) {
  (void)pFile;
  (void)zBuf;
  (void)iAmt;
  (void)iOfst;
  return SQLITE_IOERR_WRITE;
}

static int webStubTruncate(sqlite3_file *pFile, sqlite3_int64 size) {
  (void)pFile;
  (void)size;
  return SQLITE_IOERR_TRUNCATE;
}

static int webStubSync(sqlite3_file *pFile, int flags) {
  (void)pFile;
  (void)flags;
  return SQLITE_OK;
}

static int webStubFileSize(sqlite3_file *pFile, sqlite3_int64 *pSize) {
  (void)pFile;
  *pSize = 0;
  return SQLITE_OK;
}

static int webStubLock(sqlite3_file *pFile, int lock) {
  (void)pFile;
  (void)lock;
  return SQLITE_OK;
}

static int webStubUnlock(sqlite3_file *pFile, int lock) {
  (void)pFile;
  (void)lock;
  return SQLITE_OK;
}

static int webStubCheckReservedLock(sqlite3_file *pFile, int *pResOut) {
  (void)pFile;
  *pResOut = 0;
  return SQLITE_OK;
}

static int webStubFileControl(sqlite3_file *pFile, int op, void *pArg) {
  (void)pFile;
  (void)op;
  (void)pArg;
  return SQLITE_NOTFOUND;
}

static int webStubSectorSize(sqlite3_file *pFile) {
  (void)pFile;
  return 4096;
}

static int webStubDeviceCharacteristics(sqlite3_file *pFile) {
  (void)pFile;
  return 0;
}

static sqlite3_io_methods const webStubIoMethods = {
    1,
    webStubClose,
    webStubRead,
    webStubWrite,
    webStubTruncate,
    webStubSync,
    webStubFileSize,
    webStubLock,
    webStubUnlock,
    webStubCheckReservedLock,
    webStubFileControl,
    webStubSectorSize,
    webStubDeviceCharacteristics,
};

static int webStubOpen(sqlite3_vfs *pVfs, sqlite3_filename zName, sqlite3_file *pFile,
                       int flags, int *pOutFlags) {
  (void)pVfs;
  (void)zName;
  (void)flags;
  (void)pOutFlags;
  WebStubFile *stubFile = (WebStubFile *)pFile;
  memset(stubFile, 0, sizeof(*stubFile));
  stubFile->pMethods = &webStubIoMethods;
  return SQLITE_OK;
}

static int webStubDelete(sqlite3_vfs *pVfs, const char *zName, int syncDir) {
  (void)pVfs;
  (void)zName;
  (void)syncDir;
  return SQLITE_OK;
}

static int webStubAccess(sqlite3_vfs *pVfs, const char *zName, int flags, int *pResOut) {
  (void)pVfs;
  (void)zName;
  (void)flags;
  *pResOut = 0;
  return SQLITE_OK;
}

static int webStubFullPathname(sqlite3_vfs *pVfs, const char *zName, int nOut, char *zOut) {
  (void)pVfs;
  int n = (int)strlen(zName);
  if (n >= nOut) {
    return SQLITE_CANTOPEN;
  }
  memcpy(zOut, zName, (size_t)n + 1);
  return SQLITE_OK;
}

static int webStubRandomness(sqlite3_vfs *pVfs, int nByte, char *zOut) {
  (void)pVfs;
  memset(zOut, 0, (size_t)nByte);
  return SQLITE_OK;
}

static int webStubSleep(sqlite3_vfs *pVfs, int microseconds) {
  (void)pVfs;
  (void)microseconds;
  return SQLITE_OK;
}

static int webStubCurrentTimeInt64(sqlite3_vfs *pVfs, sqlite3_int64 *pTimeOut) {
  (void)pVfs;
  static const sqlite3_int64 unixEpoch = 24405875 * (sqlite3_int64)8640000;
  *pTimeOut = unixEpoch;
  return SQLITE_OK;
}

static sqlite3_vfs webStubVfs = {
    2,
    sizeof(WebStubFile),
    512,
    0,
    "webstub",
    0,
    webStubOpen,
    webStubDelete,
    webStubAccess,
    webStubFullPathname,
    0,
    0,
    0,
    0,
    webStubRandomness,
    webStubSleep,
    0,
    0,
    webStubCurrentTimeInt64,
};

int sqlite3_os_init(void) { return sqlite3_vfs_register(&webStubVfs, 1); }

int sqlite3_os_end(void) { return sqlite3_vfs_unregister(&webStubVfs); }

struct tm *localtime_r(const time_t *timep, struct tm *result) {
  (void)timep;
  (void)result;
  return 0;
}
