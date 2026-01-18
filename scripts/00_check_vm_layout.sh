#!/usr/bin/env bash
set -euo pipefail

ASC26_ROOT="${ASC26_ROOT:-$HOME/asc26}"

CODE_REPO="$ASC26_ROOT/unifolm-world-model-action"
WEIGHTS_DIR="$ASC26_ROOT/models/UnifoLM-WMA-0-Dual"
INPUT_REPO="$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization"

fail() {
  echo "[FAIL] $1"
  exit 1
}

test -d "$CODE_REPO"   || fail "Missing code repo: $CODE_REPO"
test -d "$WEIGHTS_DIR" || fail "Missing weights dir: $WEIGHTS_DIR"
test -d "$INPUT_REPO"  || fail "Missing input repo: $INPUT_REPO"

echo "[OK] Layout looks good."
echo "ASC26_ROOT = $ASC26_ROOT"
echo "CODE_REPO  = $CODE_REPO"
echo "WEIGHTS    = $WEIGHTS_DIR"
echo "INPUT_REPO = $INPUT_REPO"
