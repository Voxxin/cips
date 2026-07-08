#!/bin/bash
COBOL_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$COBOL_ROOT/src"
CPY_DIR="$COBOL_ROOT/cpy"
BUILD_DIR="$COBOL_ROOT/build"
OUTPUT_DIR="$COBOL_ROOT/output"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

RC_STEP010=0
RC_STEP020=0
RC_STEP030=0

# STEP010 - VALIDATE TRANSACTIONS
echo "[STEP010] START ValidateTransactions"
cobc -x "$SRC_DIR/ValidateTransactions.cbl" -I "$CPY_DIR" -o "$BUILD_DIR/ValidateTransactions"
cd "$OUTPUT_DIR"
"$BUILD_DIR/ValidateTransactions"
RC_STEP010=$?
if [ $RC_STEP010 -ne 0 ]; then
    echo "[STEP010] FAILED RC=$RC_STEP010"
else
    echo "[STEP010] PASSED RC=$RC_STEP010"
fi

# STEP020 - POST TRANSACTIONS (COND: skip if STEP010 RC != 0)
if [ $RC_STEP010 -eq 0 ]; then
    echo "[STEP020] START PostTransactions"
    cd "$SRC_DIR"
    cobc -x "$SRC_DIR/PostTransactions.cbl" -I "$CPY_DIR" -o "$BUILD_DIR/PostTransactions"
    cd "$OUTPUT_DIR"
    "$BUILD_DIR/PostTransactions"
    RC_STEP020=$?
    if [ $RC_STEP020 -ne 0 ]; then
        echo "[STEP020] FAILED RC=$RC_STEP020"
    else
        echo "[STEP020] PASSED RC=$RC_STEP020"
    fi
else
    echo "[STEP020] BYPASSED - STEP010 RC=$RC_STEP010"
fi

# STEP030 - REPORT TRANSACTIONS (COND=EVEN, always runs)
echo "[STEP030] START ReportTransactions"
cd "$SRC_DIR"
cobc -x "$SRC_DIR/ReportTransactions.cbl" -I "$CPY_DIR" -o "$BUILD_DIR/ReportTransactions"
cd "$OUTPUT_DIR"
"$BUILD_DIR/ReportTransactions"
RC_STEP030=$?
if [ $RC_STEP030 -ne 0 ]; then
    echo "[STEP030] FAILED RC=$RC_STEP030"
else
    echo "[STEP030] PASSED RC=$RC_STEP030"
fi

FINAL_RC=$RC_STEP010
[ $RC_STEP020 -gt $FINAL_RC ] && FINAL_RC=$RC_STEP020
[ $RC_STEP030 -gt $FINAL_RC ] && FINAL_RC=$RC_STEP030
echo "[JOB] COMPLETE FINAL-RC=$FINAL_RC"
exit $FINAL_RC