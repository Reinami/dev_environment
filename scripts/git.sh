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
        sudo apt install git

        if [[ ! -d "$HOME/.ssh" ]]; then
            echo "Creating .ssh directory..."
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"  # Secure permissions
        fi

        while true; do
            echo 
            read -p "Enter your name on git: " name
            echo    
            read -p "Enter your email on git: " email

            log_warning "You entered: "
            log_note "Name: $name"
            log_note "Email: $email"
            
            echo
            read -p "Is this correct? (y/n): " confirm
            
            if [[ $confirm == [yY] ]]; then
                break
            fi    
        done

        ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/id_rsa_$name" -N ""
        if [ $? -eq 0 ]; then
            log_info "SSH Key Generated"
            log_info "Public key is located at: $HOME/.ssh/id_rsa_$name.pub"
        else
            log_error "Failed to generate SSH Key"
            exit 1
        fi

        git config --global user.name "$name"
        git config --global user.email "$email"

        # Add ssh-agent startup block to ~/.bashrc if it doesn't exist
        ssh_agent_block="# Start ssh-agent if not already running\nif ! pgrep -u \"\$USER\" ssh-agent > /dev/null; then\n    eval \"\$(ssh-agent -s)\"\nfi"

        if ! grep -Fxq "# Start ssh-agent if not already running" "$HOME/.bashrc"; then
            echo -e "\n$ssh_agent_block" >> "$HOME/.bashrc"
        fi

        log_info "SSH key setup complete"
        log_info "Name: $name"
        log_info "Email: $email"
        log_info "Filepath: $HOME/.ssh/id_rsa_$name"
        
        GIT_SETUP=true
        GIT_SSH_KEY="$HOME/.ssh/id_rsa_$name.pub"

        notify "A Git SSH key was setup, unfortunately this can't be scripted because reasons: " 
        notify "Run these commands in order"
        notify '   eval "$(ssh-agent -s)"'
        notify "   ssh-add \"$HOME/.ssh/id_rsa_$name\""
        notify ""
        notify "Add this SSH key to git: "
        notify ""
        ssh_key_paste=$(cat $GIT_SSH_KEY)
        notify "$ssh_key_paste"
        ;;
        *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"