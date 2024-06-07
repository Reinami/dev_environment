#!/bin/bash


function setup_images() {
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    root_dir="$( dirname "$script_dir" )"
    
    image_directory="$root_dir/images"

    cp -r $image_directory $HOME/.background_images
}
