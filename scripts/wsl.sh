#!/bin/bash

# Setup scripts directory
script_name="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_utils.sh"
DRY_RUN=false

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

detect_wsl
case "$OS_TYPE" in
    pop)
        log_info "Not running WSL, doing nothing..."
        ;;
    ubuntu)
        if [ "$IS_WSL" = "true" ]; then
            sudo apt install unzip -y

            url="https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip"
            executable="win32yank.exe"
            install_dir="/usr/local/bin"

            # Download and install
            log_info "Downloading and installing win32yank..."

            # Create a temporary directory
            temp_dir=$(mktemp -d) || log_error "Failed to create temporary directory."

            # Download the zip file and unzip it to the temporary directory
            wget -q -O "$temp_dir/win32yank.zip" "$url" || log_error "Failed to download $url."
            unzip -q "$temp_dir/win32yank.zip" -d "$temp_dir" || log_error "Failed to unzip $temp_dir/win32yank.zip."

            # Move the executable to /usr/local/bin
            sudo mv "$temp_dir/$executable" "$install_dir" || log_error "Failed to move $executable to $install_dir."

            # Grant executable permissions
            sudo chmod +x "$install_dir/$executable" || log_error "Failed to grant executable permissions to $install_dir/$executable."

            # Clean up
            rm -rf "$temp_dir" || log_error "Failed to remove temporary directory $temp_dir."

            # Make docker work
            append_to_bashrc 'export PATH=$PATH:/mnt/wsl/docker-desktop/cli-tools'
            sudo ln -s /mnt/wsl/docker-desktop/cli-tools/docker-credential-desktop.exe /usr/local/bin/docker-credential-desktop.exe
            mkdir -p ~/.docker && echo '{ "credsStore": "desktop.exe" }' | tee ~/.docker/config.json > /dev/null
        else
            log_info "Not running WSL, doing nothing..."
        fi
        ;;
    *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"
