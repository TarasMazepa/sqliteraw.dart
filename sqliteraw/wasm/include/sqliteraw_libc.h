#ifndef SQLITERAW_LIBC_H
#define SQLITERAW_LIBC_H

typedef __SIZE_TYPE__ size_t;
typedef __PTRDIFF_TYPE__ ptrdiff_t;
typedef __WCHAR_TYPE__ wchar_t;

#define NULL ((void *)0)
#define offsetof(type, member) __builtin_offsetof(type, member)

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

typedef int32_t intptr_t;
typedef uint32_t uintptr_t;

#define CHAR_BIT 8
#define INT_MAX 2147483647
#define INT32_MAX 2147483647
#define UINT32_MAX 4294967295u
#define INT64_MAX 9223372036854775807LL
#define UINT64_MAX 18446744073709551615ULL
#define LONG_MAX 2147483647L
#define ULONG_MAX 4294967295UL

#define INT64_C(value) value##LL
#define UINT64_C(value) value##ULL

#define PRId32 "d"
#define PRIi32 "i"
#define PRIu32 "u"
#define PRIx32 "x"
#define PRIX32 "X"
#define PRId64 "lld"
#define PRIi64 "lli"
#define PRIu64 "llu"
#define PRIx64 "llx"
#define PRIX64 "llX"

typedef __builtin_va_list va_list;

#define va_start(ap, param) __builtin_va_start(ap, param)
#define va_end(ap) __builtin_va_end(ap)
#define va_arg(ap, type) __builtin_va_arg(ap, type)
#define va_copy(dest, src) __builtin_va_copy(dest, src)

#define assert(expr) ((void)0)

static inline int sqliteraw_isspace(int c) {
  return c == ' ' || c == '\f' || c == '\n' || c == '\r' || c == '\t' || c == '\v';
}

static inline int sqliteraw_isdigit(int c) { return c >= '0' && c <= '9'; }

static inline int sqliteraw_isalpha(int c) {
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
}

static inline int sqliteraw_isalnum(int c) {
  return sqliteraw_isalpha(c) || sqliteraw_isdigit(c);
}

static inline int sqliteraw_isxdigit(int c) {
  return sqliteraw_isdigit(c) || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f');
}

static inline int sqliteraw_toupper(int c) {
  return (c >= 'a' && c <= 'z') ? c - 32 : c;
}

static inline int sqliteraw_tolower(int c) {
  return (c >= 'A' && c <= 'Z') ? c + 32 : c;
}

#define isspace sqliteraw_isspace
#define isdigit sqliteraw_isdigit
#define isalpha sqliteraw_isalpha
#define isalnum sqliteraw_isalnum
#define isxdigit sqliteraw_isxdigit
#define toupper sqliteraw_toupper
#define tolower sqliteraw_tolower

void *memcpy(void *dest, const void *src, size_t n);
void *memmove(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
int memcmp(const void *s1, const void *s2, size_t n);
void *memchr(const void *s, int c, size_t n);

size_t strlen(const char *s);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t n);
char *strchr(const char *s, int c);
char *strrchr(const char *s, int c);
size_t strcspn(const char *s, const char *reject);
size_t strspn(const char *s, const char *accept);

void *malloc(size_t size);
void free(void *pointer);
void *realloc(void *pointer, size_t size);
void qsort(void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *));

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

typedef struct SqliterawWasmFile {
  int unused;
} FILE;

#define EOF (-1)
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;

int snprintf(char *str, size_t size, const char *format, ...);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);
int fprintf(FILE *stream, const char *format, ...);
int printf(const char *format, ...);
int fflush(FILE *stream);

#define INFINITY (__builtin_inff())
#define NAN (__builtin_nanf(""))

double log(double x);
double fabs(double x);

typedef long time_t;

struct tm {
  int tm_sec;
  int tm_min;
  int tm_hour;
  int tm_mday;
  int tm_mon;
  int tm_year;
  int tm_wday;
  int tm_yday;
  int tm_isdst;
};

struct tm *localtime_r(const time_t *timep, struct tm *result);

#endif
