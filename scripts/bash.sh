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
    pop)
        cp git/.git-prompt.sh ~/
        local git_prompt_line="PROMPT_COMMAND='PS1_CMD1=\$(__git_ps1 \" (%s)\")'; PS1='[\\[\\e[32m\\]\\u\\[\\e[0m\\]@\\[\\e[95m\\]\\h\\[\\e[0m\\] \\[\\e[96m\\]\\w\\[\\e[0m\\]]\\[\\e[90m\\]\${PS1_CMD1}\\[\\e[0m\\] \\[\\e[91m\\]λ\\[\\e[0m\\] '"
        local git_source_line="source ~/.git-prompt.sh"

        append_to_bashrc "$git_prompt_line"
        append_to_bashrc "$git_source_line"
        ;;
    *)
        log_error "Unsupported OS $OS_TYPE"
        exit 1
        ;;
esac

log_success "Done with $script_name"