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

