#!/bin/bash

function install_deps() {
    sudo apt-get update
    sudo apt-get install gcc git cron jq
    
    sudo systemctl start cron
    sudo systemctl enable cron
}
