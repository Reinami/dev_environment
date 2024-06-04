#!/bin/bash

function setup_bashrc() {
    cp scripts/.git-prompt.sh ~/.git-prompt.sh
    cp .bashrc ~/.bashrc
    source ~/.bashrc
}
