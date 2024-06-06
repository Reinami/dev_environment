#!/bin/bash


function setup_wsl() {
    source ./scripts/images.sh
    setup_images
    symlink_wsl
}

function symlink_wsl() {
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    root_dir="$( dirname "$script_dir" )"
    
    wsl_directory="$root_dir/wsl"

    ln -s $wsl_directory $HOME/.wsl
}
