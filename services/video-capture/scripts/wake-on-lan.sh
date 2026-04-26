#!/usr/bin/env bash
# 通过 etherwake 发送 Wake-on-LAN 魔术包唤醒目标主机

set -euo pipefail

# ========== 在此处配置默认值 ==========
DEFAULT_IFACE="eth0"
DEFAULT_MAC="xx:xx:xx:xx:xx:xx"
# =====================================

print_help() {
    cat <<EOF
用法: bash wake-on-lan.sh [INTERFACE] [MAC_ADDRESS]

参数:
  INTERFACE    网络接口名称，默认: ${DEFAULT_IFACE}
  MAC_ADDRESS  目标主机 MAC 地址（格式: xx:xx:xx:xx:xx:xx 或 xx-xx-xx-xx-xx-xx）
               未指定时使用脚本内配置的 DEFAULT_MAC

示例:
  bash wake-on-lan.sh                              # 使用全部默认值
  bash wake-on-lan.sh eth1                         # 指定网卡
  bash wake-on-lan.sh eth0 11:22:33:44:55:66      # 全量指定

EOF
}

preflight_check() {
    if ! command -v etherwake &>/dev/null; then
        echo "[ERROR] 未找到 etherwake，请安装: sudo apt install etherwake" >&2
        exit 1
    fi
}

validate_mac() {
    if ! echo "$1" | grep -qE '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'; then
        echo "[ERROR] MAC 地址格式无效: $1（正确格式: xx:xx:xx:xx:xx:xx 或 xx-xx-xx-xx-xx-xx）" >&2
        exit 1
    fi
}

send_wol() {
    echo "[INFO] 网络接口: ${1}" >&2
    echo "[INFO] 目标 MAC: ${2}" >&2
    echo "[INFO] 正在发送 Wake-on-LAN 魔术包..." >&2

    if sudo etherwake -i "$1" "$2"; then
        echo "[OK] 魔术包已发送至 ${2}" >&2
    else
        echo "[ERROR] 发送失败，请检查网络接口 ${1} 是否存在且有权限" >&2
        exit 1
    fi
}

main() {
    case "${1:-}" in
        -h|--help|help)
            print_help
            exit 0
            ;;
    esac

    local iface="${1:-${DEFAULT_IFACE}}"
    local mac="${2:-${DEFAULT_MAC}}"

    preflight_check
    validate_mac "$mac"
    send_wol "$iface" "$mac"
}

main "${@}"
