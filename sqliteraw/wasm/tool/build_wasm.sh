#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
wasm_dir="$(cd "${script_dir}/.." && pwd)"
package_dir="$(cd "${wasm_dir}/.." && pwd)"
repo_root="$(cd "${package_dir}/.." && pwd)"

sqlite_dir="${repo_root}/sqlite"
src_dir="${wasm_dir}/src"
include_dir="${wasm_dir}/include"
out_dir="${wasm_dir}/out"
out_file="${out_dir}/sqliteraw.wasm"
wasm_target="wasm32-unknown-unknown"

resolve_executable() {
  local candidate="$1"
  if [ -z "${candidate}" ]; then
    return 1
  fi
  if [ -x "${candidate}" ]; then
    echo "${candidate}"
    return 0
  fi
  # Bare command names (e.g. CI sets CLANG=clang-18) need PATH lookup.
  if [[ "${candidate}" != /* ]]; then
    local resolved
    resolved="$(command -v "${candidate}" 2>/dev/null || true)"
    if [ -n "${resolved}" ] && [ -x "${resolved}" ]; then
      echo "${resolved}"
      return 0
    fi
  fi
  return 1
}

resolve_clang() {
  if [ -n "${CLANG:-}" ]; then
    candidates=("${CLANG}")
  else
    candidates=(
      "/opt/homebrew/opt/llvm/bin/clang"
      "/usr/local/opt/llvm/bin/clang"
      "$(command -v clang 2>/dev/null || true)"
    )
  fi

  for candidate in "${candidates[@]}"; do
    local resolved
    resolved="$(resolve_executable "${candidate}" || true)"
    if [ -z "${resolved}" ]; then
      continue
    fi
    if "${resolved}" --target="${wasm_target}" -c -x c /dev/null -o /dev/null 2>/dev/null; then
      echo "${resolved}"
      return 0
    fi
  done

  return 1
}

resolve_wasm_ld() {
  local candidates=(
    "${WASM_LD:-}"
    "$(command -v wasm-ld 2>/dev/null || true)"
    "/opt/homebrew/bin/wasm-ld"
    "/usr/local/bin/wasm-ld"
    "/opt/homebrew/opt/llvm/bin/wasm-ld"
    "/usr/local/opt/llvm/bin/wasm-ld"
  )

  for candidate in "${candidates[@]}"; do
    local resolved
    resolved="$(resolve_executable "${candidate}" || true)"
    if [ -n "${resolved}" ]; then
      echo "${resolved}"
      return 0
    fi
  done

  return 1
}

clang="$(resolve_clang || true)"
if [ -z "${clang}" ]; then
  echo "No clang with WebAssembly support found."
  echo "Install LLVM with wasm target, e.g.:"
  echo "brew install llvm lld"
  echo "Then run:"
  echo "export PATH=\"/opt/homebrew/opt/llvm/bin:/opt/homebrew/bin:\$PATH\""
  echo "sqliteraw/wasm/tool/build_wasm.sh"
  exit 1
fi

wasm_ld="$(resolve_wasm_ld || true)"
if [ -z "${wasm_ld}" ]; then
  echo "wasm-ld not found. Install lld, e.g.:"
  echo "brew install lld"
  exit 1
fi

clang_bin_dir="$(cd "$(dirname "${clang}")" && pwd)"
wasm_ld_bin_dir="$(cd "$(dirname "${wasm_ld}")" && pwd)"
export PATH="${clang_bin_dir}:${wasm_ld_bin_dir}:${PATH}"

echo "Using ${clang} (--target=${wasm_target})"
export_flags="-Wl,--export=malloc -Wl,--export=free -Wl,--export=sqliteraw_sql_clear -Wl,--export=sqliteraw_sql_append_byte -Wl,--export=sqliteraw_memory_read -Wl,--export=sqliteraw_memory_write -Wl,--export=sqliteraw_memory_read_i32 -Wl,--export=sqliteraw_memory_write_i32 -Wl,--export=sqliteraw_open_memdb -Wl,--export=sqliteraw_db_handle -Wl,--export=sqliteraw_exec_buffered -Wl,--export=sqliteraw_changes -Wl,--export=sqliteraw_errmsg_ptr -Wl,--export=sqliteraw_prepare_buffered -Wl,--export=sqliteraw_step -Wl,--export=sqliteraw_column_int -Wl,--export=sqliteraw_column_text_ptr -Wl,--export=sqliteraw_finalize -Wl,--export=sqliteraw_close -Wl,--export=sqlite3_initialize -Wl,--export=sqlite3_libversion"

mkdir -p "${out_dir}"

gen_include_dir="${out_dir}/include"
mkdir -p "${gen_include_dir}"
cp "${include_dir}/sqliteraw_libc.h" "${gen_include_dir}/sqliteraw_libc.h"
for header in stddef stdint limits stdarg assert ctype string stdlib stdio math time inttypes; do
  printf '#include "sqliteraw_libc.h"\n' >"${gen_include_dir}/${header}.h"
done

# Browser wasm: bundled headers + nostdlib, no WASI imports.
"${clang}" --target="${wasm_target}" \
  -std=c23 -Oz -DNDEBUG \
  -DSQLITE_OS_OTHER=1 \
  -DSQLITE_THREADSAFE=0 \
  -DSQLITE_OMIT_WAL=1 \
  -DSQLITE_TEMP_STORE=3 \
  -DSQLITE_DQS=0 \
  -DSQLITE_DEFAULT_MEMSTATUS=0 \
  -DSQLITE_LIKE_DOESNT_MATCH_BLOBS=1 \
  -DSQLITE_STRICT_SUBTYPE=1 \
  -DSQLITE_BYTEORDER=1234 \
  -DHAVE_LOCALTIME_R=1 \
  -DSQLITE_OMIT_DEPRECATED \
  -DSQLITE_OMIT_LOAD_EXTENSION \
  -DSQLITE_OMIT_UTF16 \
  -DSQLITE_DISABLE_DIRSYNC \
  -DSQLITE_ENABLE_FTS4 \
  -DSQLITE_ENABLE_FTS5 \
  -DSQLITE_ENABLE_RTREE \
  -DSQLITE_ENABLE_GEOPOLY \
  -DSQLITE_API='__attribute__((visibility("default")))' \
  -D__WASM__ \
  -fno-stack-protector \
  -nostdlib \
  -isystem "${gen_include_dir}" \
  -I "${sqlite_dir}" \
  -o "${out_file}" \
  "${sqlite_dir}/sqlite3.c" \
  "${src_dir}/sqliteraw.c" \
  -Wl,--no-entry \
  -Wl,--export-memory \
  ${export_flags}

echo "Built ${out_file}"
