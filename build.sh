#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Get the directory of the script
script_dir=$(cd "$(dirname "$0")" && pwd)

# Detect OS and architecture
os=$(uname -s)
arch=$(uname -m)

target=""
lib_ext=""
exe_ext=""
platform_dir=""

if [ "$os" = "Linux" ]; then
    target="x86_64-linux-gnu"
    lib_ext="so"
    exe_ext=""
    platform_dir="linux-x86_64"
elif [ "$os" = "Darwin" ]; then
    lib_ext="dylib"
    exe_ext=""
    if [ "$arch" = "x86_64" ]; then
        target="x86_64-macos-none"
        platform_dir="macos-x86_64"
    elif [ "$arch" = "arm64" ] || [ "$arch" = "aarch64" ]; then
        target="aarch64-macos-none"
        platform_dir="macos-aarch64"
    else
        echo "Unsupported macOS architecture: $arch"
        exit 1
    fi
else
    echo "Unsupported OS: $os"
    exit 1
fi

# Create a build directory for the platform if it doesn't exist
build_dir="$script_dir/build/$platform_dir"
mkdir -p "$build_dir"

# Compile sqlite3.c into a shared library
echo "Compiling sqlite3.c into a shared library for $platform_dir..."
zig cc -target $target -shared "$script_dir/sqlite/sqlite3.c" -o "$build_dir/sqlite3.$lib_ext"
echo "Successfully created $build_dir/sqlite3.$lib_ext"

# Compile shell.c and sqlite3.c into an executable
echo "Compiling shell.c into an executable for $platform_dir..."
zig cc -target $target "$script_dir/sqlite/sqlite3.c" "$script_dir/sqlite/shell.c" -o "$build_dir/sqlite3$exe_ext"
echo "Successfully created $build_dir/sqlite3$exe_ext"

echo "Build finished successfully for $platform_dir." 