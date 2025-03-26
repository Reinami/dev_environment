#!/bin/bash

RED='\e[1;91m'
GREEN='\e[1;92m'
YELLOW='\e[1;93m'
BLUE='\e[1;94m'
PURPLE='\e[1;95m'
CYAN='\e[1;96m'
YELLOW_BG='\e[0;103m'
NC='\033[0m'  # No Color

log_task() {
    echo -e "${PURPLE}[TASK] $1${NC}"
}

log_note() {
    echo -e "${CYAN}[NOTE] $1${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

log_dry() {
    local log_func="$1"
    shift
    echo -ne "${YELLOW_BG}{DRY-RUN}${NC} "
    "$log_func" "$*"
}

notify() {
    if [ -z "$NOTIFY_FILE" ]; then
        echo "Warning: NOTIFY_FILE is not set. Notification: $1" >&2
    else
        echo "$1" >> "$NOTIFY_FILE"
    fi
}

detect_os() {
    local os=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            pop)
                os="pop"
                ;;
            *)
                os="unknown"
                ;;
        esac
    elif [[ "OSTYPE" == "darwin"* ]]; then
        os="macos"
    else
        os="unknown"
    fi

    export OS_TYPE="$os"
}
