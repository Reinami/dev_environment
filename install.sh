#!/bin/bash

scripts=(
    "os.sh"
    "bash.sh"
    "node.sh"
    "git.sh"
    "python.sh"
    "golang.sh"
    "docker.sh"
    "neovim.sh"
    "wsl.sh"
)

supported_os=(
    "pop"
    "ubuntu"
)

# Setup scripts directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"
chmod +x "$SCRIPT_DIR"/*.sh
source "$SCRIPT_DIR/_utils.sh"

# Setup ENV
detect_os

# Validations
found=false
for os in "${supported_os[@]}"; do
    if [[ "$os" == "$OS_TYPE" ]]; then
        found=true
        break
    fi
done

if ! $found; then
    log_error "Detect \"$OS_TYPE\" as operating system, it is not currently supported."
    exit 1
fi

# Create or clear the notifications file
NOTIFY_FILE="$SCRIPT_DIR/notifications.tmp"
> "$NOTIFY_FILE"   # This truncates (or creates) the file
export NOTIFY_FILE  # Export so that sub-scripts can access it

# Run the thing
log_task "Setting up entire environment"

# Check if --dry is present among all arguments
if [[ " $@ " =~ " --dry" ]]; then
    log_dry log_info "Running in dry-run mode. No changes will be applied."
fi

for script in "${scripts[@]}"; do
    bash "$SCRIPT_DIR/$script" "$@"
done

# Read notifications from the file into an array
notifications=()
while IFS= read -r line; do
    notifications+=("$line")
done < "$NOTIFY_FILE"
rm "$NOTIFY_FILE"

if [ ${#notifications[@]} -ne 0 ]; then
    log_info "Summary of actions:"
    for notification in "${notifications[@]}"; do
        log_note "$notification"
    done
fi

log_success "Setup Complete"