#!/bin/bash

GO_VERSION="${GO_VERSION:-latest}"

# Setup scripts directory
script_name="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_utils.sh"
DRY_RUN=false
setup_script

for arg in "$@"; do
    if [ "$arg" == "--dry" ]; then
        DRY_RUN=true
        break
    fi
done

if [ "$DRY_RUN" = true ]; then
    log_dry log_info "$script_name: Would execute setup tasks."
    notify "$script_name: (dry-run simulated notification)"
    exit 0
fi

log_note "Starting $script_name..."

case "$OS_TYPE" in
    pop|ubuntu)
        if [ "$GO_VERSION" = "latest" ]; then
            GO_VERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n 1)"
        fi

        go_archive="${GO_VERSION}.linux-amd64.tar.gz"

        curl -fsSLO "https://go.dev/dl/${go_archive}"
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$go_archive"
        append_to_bashrc 'export PATH=$PATH:/usr/local/go/bin'

        rm "$go_archive"
        ;;
    *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"
