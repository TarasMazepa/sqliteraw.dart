# build.ps1

# Get the directory of the script
$scriptDir = $PSScriptRoot

# Define platform directory
$platformDir = "windows-x86_64"

# Create a build directory for the platform if it doesn't exist
$buildDir = Join-Path -Path $scriptDir -ChildPath "build/$platformDir"
if (-not (Test-Path -Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force
}

# Compile sqlite3.c into a shared library
Write-Host "Compiling sqlite3.c into a shared library for $platformDir..."
zig cc -target native-native-gnu -shared "$scriptDir/sqlite/sqlite3.c" -o "$buildDir/sqlite3.dll"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to compile sqlite3.c into a shared library."
    exit 1
}
Write-Host "Successfully created $buildDir/sqlite3.dll"


# Compile shell.c and sqlite3.c into an executable
Write-Host "Compiling shell.c into an executable for $platformDir..."
zig cc -target native-native-gnu "$scriptDir/sqlite/shell.c" "$scriptDir/sqlite/sqlite3.c" -o "$buildDir/sqlite3.exe"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to compile shell.c into an executable."
    exit 1
}

Write-Host "Successfully created $buildDir/sqlite3.exe"

Write-Host "Build finished successfully for $platformDir." 