#!/bin/bash

function nvim_symlink() {
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    root_dir="$( dirname "$script_dir" )"
    
    nvim_directory="$root_dir/nvim"

    ln -s $nvim_directory $XDG_CONFIG_HOME/nvim
}

