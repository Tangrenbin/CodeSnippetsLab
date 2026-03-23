#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_IMAGE="SDK/STD_2016bin/ZCDBM-0FB05-R1080A.16-2603181808.bin"
DEFAULT_LOG="SDK/STD_2016bin/upgrade.log"

resolve_path() {
    local raw="$1"
    if [[ "$raw" = /* ]]; then
        printf '%s\n' "$raw"
    else
        printf '%s\n' "$SCRIPT_DIR/$raw"
    fi
}

usage() {
    cat <<'EOF'
Usage:
  ./run_com11_upgrade.sh [image_path] [port] [log_path]

Defaults:
  image_path = SDK/STD_2016bin/ZCDBM-0FB05-R1080A.16-2603181808.bin
  port       = COM11
  log_path   = SDK/STD_2016bin/upgrade.log

Examples:
  ./run_com11_upgrade.sh
  ./run_com11_upgrade.sh SDK/STD_2016bin/other.bin
  ./run_com11_upgrade.sh SDK/STD_2016bin/other.bin COM12
  ./run_com11_upgrade.sh SDK/STD_2016bin/other.bin COM11 logs/upgrade.log
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

IMAGE_INPUT="${1:-$DEFAULT_IMAGE}"
PORT="${2:-COM11}"
LOG_INPUT="${3:-$DEFAULT_LOG}"

cd "$SCRIPT_DIR"

IMAGE_PATH="$(resolve_path "$IMAGE_INPUT")"
LOG_PATH="$(resolve_path "$LOG_INPUT")"

if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "image not found: $IMAGE_INPUT" >&2
    exit 1
fi

mkdir -p "$(dirname "$LOG_PATH")"

WIN_SCRIPT_PATH="$(wslpath -w "$SCRIPT_DIR/serial_upgrade.py")"
WIN_IMAGE_PATH="$(wslpath -w "$IMAGE_PATH")"
WIN_LOG_PATH="$(wslpath -w "$LOG_PATH")"

cmd.exe /c py -3 "$WIN_SCRIPT_PATH" --port "$PORT" --image "$WIN_IMAGE_PATH" --log-path "$WIN_LOG_PATH"
