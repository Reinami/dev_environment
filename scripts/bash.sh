#!/bin/bash

# Setup scripts directory
script_name="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_utils.sh"
DRY_RUN=false

for arg in "$@"; do
    if [ "$arg" == "--dry-run" ]; then
        DRY_RUN=true
        break
    fi
done

if [ "$DRY_RUN" = true ]; then
    log_dry log_info "$script_name: Would execute setup tasks."
    notify "$script_name: (dry-run simulated notification)"
    exit 0
fi
