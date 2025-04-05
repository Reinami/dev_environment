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
    local caller_script
    caller_script=$(basename "${BASH_SOURCE[1]}")
    echo -e "${PURPLE}[TASK] $caller_script - $1${NC}"
}

log_note() {
    local caller_script
    caller_script=$(basename "${BASH_SOURCE[1]}")
    echo -e "${CYAN}[NOTE] $caller_script - $1${NC}"
}

log_info() {
    local caller_script
    caller_script=$(basename "${BASH_SOURCE[1]}")
    echo -e "${BLUE}[INFO] $caller_script - $1${NC}"
}

log_success() {
    local caller_script
    caller_script=$(basename "${BASH_SOURCE[1]}")
    echo -e "${GREEN}[SUCCESS] $caller_script - $1${NC}"
}

log_warning() {
    local caller_script
    caller_script=$(basename "${BASH_SOURCE[1]}")
    echo -e "${YELLOW}[WARNING] $caller_script - $1${NC}"
}

log_error() {
    local caller_script
    caller_script=$(basename "${BASH_SOURCE[1]}")
    echo -e "${RED}[ERROR] $caller_script - $1${NC}"
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
            ubuntu)
                os="ubuntu"
                ;;
            *)
                os="unknown"
                ;;
        esac
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="macos"
    else
        os="unknown"
    fi

    export OS_TYPE="$os"
}

detect_wsl() {
    if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        export IS_WSL=true
    else
        export IS_WSL=false
    fi
}

append_to_bashrc() {
    local line="$1"
    if ! grep -Fxq "$line" "$HOME/.bashrc"; then
        log_info "Appending: $line to $HOME/.bashrc"
        echo "$line" >> "$HOME/.bashrc"
    else
        log_warning "$line is already present in $HOME/.bashrc"
    fi
}

setup_script() {
    detect_os
}