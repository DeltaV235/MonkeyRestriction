#!/usr/bin/env bash
# 用法: bash raspi-stream.sh <MAC_IP> [PORT] [WIDTH] [HEIGHT] [FPS]
# 将 OV5647 摄像头视频通过硬件 H.264 编码推送到 Mac 端 ffplay

set -euo pipefail

MAC_IP="${1:?用法: raspi-stream.sh <MAC_IP> [PORT] [WIDTH] [HEIGHT] [FPS]}"
PORT="${2:-5000}"
WIDTH="${3:-640}"
HEIGHT="${4:-480}"
FPS="${5:-15}"

RPICAM_PID=""
FFMPEG_PID=""
FIFO_DIR=""

preflight_check() {
    if ! command -v rpicam-vid &>/dev/null; then
        echo "[ERROR] 未找到 rpicam-vid，请安装 rpicam-apps" >&2
        exit 1
    fi
    if ! command -v ffmpeg &>/dev/null; then
        echo "[ERROR] 未找到 ffmpeg，请安装 ffmpeg" >&2
        exit 1
    fi
    local cam_list
    cam_list=$(rpicam-hello --list-cameras 2>&1) || true
    if ! echo "$cam_list" | grep -q "Available cameras"; then
        echo "[ERROR] 未检测到摄像头，请检查 CSI 连接和 raspi-config" >&2
        exit 1
    fi
}

setup_trap() {
    cleanup() {
        [[ -n "$RPICAM_PID" ]] && kill "$RPICAM_PID" 2>/dev/null || true
        [[ -n "$FFMPEG_PID" ]] && kill "$FFMPEG_PID" 2>/dev/null || true
        [[ -n "$FIFO_DIR" ]] && rm -rf "$FIFO_DIR" 2>/dev/null || true
        wait 2>/dev/null || true
    }
    trap cleanup HUP INT TERM EXIT
}

run_pipeline() {
    echo "[INFO] 推流目标: tcp://${MAC_IP}:${PORT}" >&2
    echo "[INFO] 分辨率: ${WIDTH}x${HEIGHT}@${FPS}fps" >&2
    echo "[INFO] 请确保 Mac 端已先执行: bash mac-listen.sh ${PORT}" >&2
    echo "[INFO] 等待连接..." >&2

    FIFO_DIR=$(mktemp -d /tmp/raspi-stream-XXXXXX)
    local FIFO="${FIFO_DIR}/stream.fifo"
    mkfifo "$FIFO"

    rpicam-vid \
        --width "$WIDTH" \
        --height "$HEIGHT" \
        --framerate "$FPS" \
        --codec h264 \
        --inline \
        --nopreview \
        --intra 30 \
        -t 0 \
        -o "$FIFO" &
    RPICAM_PID="$!"

    ffmpeg \
        -loglevel info \
        -f h264 \
        -i "$FIFO" \
        -c:v copy \
        -an \
        -f mpegts \
        "tcp://${MAC_IP}:${PORT}" &
    FFMPEG_PID="$!"

    wait -n
}

preflight_check
setup_trap
run_pipeline
