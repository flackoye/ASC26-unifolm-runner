#!/usr/bin/env bash
set -euo pipefail

test -d "/home/bohao-fang/asc26/unifolm-world-model-action" || { echo "Missing code repo"; exit 1; }
test -d "/home/bohao-fang/asc26/models/UnifoLM-WMA-0-Dual" || { echo "Missing weights"; exit 1; }
test -d "/home/bohao-fang/asc26/ASC26-Embodied-World-Model-Optimization" || { echo "Missing input repo"; exit 1; }

echo "[OK] VM layout looks good."
