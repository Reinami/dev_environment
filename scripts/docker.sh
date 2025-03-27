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

case "$OS_TYPE" in
    pop)
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        sudo groupadd docker
        sudo usermod -aG docker $USER

        newgrp docker

        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service
        ;;
    *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"