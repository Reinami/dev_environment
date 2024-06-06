PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s) ")'; PS1='[\[\e[92;1m\]\u\[\e[0m\]:\[\e[96;1m\]\w\[\e[0m\]]\[\e[91;1m\]${PS1_CMD1}\[\e[37;2m\]\\$\[\e[0m\]'

source ~/.git-prompt.sh

alias vim="nvim"
alias ll="ls -la"

export XDG_CONFIG_HOME=$HOME/.config

export NVM_DIR="$HOME/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add SSH keys if they aren't there
if [ -z "$SSH_AUTH_SOCL" ]; then
    eval `ssh-agent -s`
    for keyfile in ~/.ssh/id_rsa*; do
        if [[ "$keyfile" != *.pub ]]; then
            ssh-add "$keyfile"
        fi
    done
fi

# If WSL and WSL settings.json file is setup, set the env for it
if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Distro name exists"
    config_file_location="$HOME/wsl/wsl_config_path.txt"

    if [ -f "$config_file_location" ]; then
        echo "File exists"
        FILE_CONTENTS=$(cat "$config_file_location")

        export WSL_SETTINGS_JSON_PATH="$FILE_CONTENTS"
    fi
fi

# If background images are used, set the path to them in the env
images_dir_path="$HOME/.background_images"
if [ -d "$images_dir_path" ]; then
    echo "images dir exists"
    export BACKGROUND_IMAGES_DIR="$images_dir_path"
fi
