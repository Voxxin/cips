#!/bin/bash
set -e

COBOL_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$COBOL_ROOT/src"
CPY_DIR="$COBOL_ROOT/cpy"
BUILD_DIR="$COBOL_ROOT/build"
OUTPUT_DIR="$COBOL_ROOT/output"

mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

cobc -x "$SRC_DIR/ValidateTransactions.cbl" -I "$CPY_DIR" -o "$BUILD_DIR/ValidateTransactions"

cd "$OUTPUT_DIR"
"$BUILD_DIR/ValidateTransactions"

exit_code0=$?
if [ $exit_code0 -ne 0 ]; then
    echo "ValidateTransactions failed with exit code $exit_code0"
    exit 1
else
    echo "ValidateTransactions completed successfully with exit code $exit_code0"
    echo ""
    
    echo "Starting PostTransactions"
    
    cd "$SRC_DIR"
    cobc -x "$SRC_DIR/PostTransactions.cbl" -I "$CPY_DIR" -o "$BUILD_DIR/PostTransactions"

    cd "$OUTPUT_DIR"
    "$BUILD_DIR/PostTransactions"
fi