#!/usr/bin/env bash
# 用法: bash mac-listen.sh [PORT]
# 低延迟监听来自树莓派的 MPEG-TS 视频流

set -euo pipefail

PORT="${1:-5000}"

echo "[INFO] 等待 Pi 连接到端口 ${PORT}..." >&2

ffplay \
    -fflags nobuffer \
    -flags low_delay \
    -framedrop \
    -i "tcp://0.0.0.0:${PORT}?listen"
