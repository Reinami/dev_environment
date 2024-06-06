#!/bin/bash

function nvim_symlink() {
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    root_dir="$( dirname "$script_dir" )"
    
    nvim_directory="$root_dir/nvim"

    ln -s $nvim_directory $XDG_CONFIG_HOME/nvim
}

function nvim_setup() {
    # download nvm
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage 
    chmod u+x nvim.appimage    
    
    # extract it
    ./nvim.appimage --appimage-extract 
    ./squashfs-root/AppRun --version
    
    # make it usable everywhere
    sudo mv squashfs-root / 
    sudo ln -s /squashfs-root/AppRun /usr/bin/nvim 
    
    # delete files
    rm ./nvim.appimage

    nvim_symlink
    setup_packer
}

function setup_packer() {
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim 
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

