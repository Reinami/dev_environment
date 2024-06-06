#!/bin/bash


function init_dev_environment() {
    source ./scripts/deps.sh
    source ./scripts/git.sh
    source ./scripts/bash.sh
    source ./scripts/nvim.sh
   

    # install deps
    install_deps    
    
    # install git
    setup_git 

    # setup bash
    setup_bashrc

    # install nvim
    setup_nvim
}
