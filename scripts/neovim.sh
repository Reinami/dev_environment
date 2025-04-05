#!/bin/bash

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
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
        chmod u+x nvim-linux-x86_64.appimage
        
        sudo mkdir -p /opt/nvim
        sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
           
        append_to_bashrc 'PATH="$PATH:/opt/nvim/"'
        append_to_bashrc "alias oldvim='vim'"
        append_to_bashrc "alias vim='nvim'"

        mkdir -p ~/.config && cp -r ./neovim/.config/nvim/ ~/.config/nvim/
        ;;
    *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"
