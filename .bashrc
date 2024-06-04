PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s) ")'; PS1='[\[\e[92;1m\]\u\[\e[0m\]:\[\e[96;1m\]\w\[\e[0m\]]\[\e[91;1m\]${PS1_CMD1}\[\e[37;2m\]\\$\[\e[0m\]'

source ~/.git-prompt.sh

export PATH="$PATH:/opt/nvim-linux64/bin"
export XDG_CONFIG_HOME="$HOME"
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

alias vim="nvim"
alias oldvim="vim"
alias ll="ls -la"
. "$HOME/.cargo/env"

export NVM_DIR="$HOME/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
