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
        curl -fsSL https://pyenv.run | bash

        append_to_bashrc 'export PYENV_ROOT="$HOME/.pyenv"'
        append_to_bashrc '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
        append_to_bashrc 'eval "$(pyenv init - bash)"'
        ;;
    *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"