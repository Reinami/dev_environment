#!/bin/bash


function setup_wsl() {
    source ./scripts/images.sh
    setup_images
    symlink_wsl

    update_env_variables
}

function symlink_wsl() {
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    root_dir="$( dirname "$script_dir" )"
    
    wsl_directory="$root_dir/wsl"

    ln -s $wsl_directory $HOME/.wsl
}

function update_env_variables() {
    read -p "What is the path to your settings.json for your config? " config_path
    wsl_config_path_text_file="$HOME/wsl/wsl_config_path.txt"    
    echo "$config_path" > "$wsl_config_path_text_file"
}
