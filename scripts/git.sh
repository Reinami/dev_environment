#!/bin/bash

function generate_ssh_key() {
    while true; do
        read -p "Enter your name: " name
        read -p "Enter your email: " email

        echo "You entered: "
        echo "Name: $name"
        echo "Email: $email"

        read -p "Is this correct? (y/n): " confirm

        if [[ $confirm == [yY] ]]; then
            break
        fi
    done

    # Generate SSH Key
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/id_rsa_$name" -N ""
    if [ $? -eq 0 ]; then
        echo "SSH Key Generated"
        echo "Public key is located at: $HOME/.ssh/id_rsa_$name.pub"
    else
        echo "Failed to generate SSH Key."
        exit 1
    fi

    # Add key to agent
    
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_rsa_$name"
    if [ $? -eq 0 ]; then
        echo "SSH Key added to agent."
    else
        echo "Failed to add SSH key to agent"
        exit 1
    fi

    git config --global user.name "$name"
    git config --global user.email "$email"

    echo "SSH Key setup is complete"
    echo "Name: $name"
    echo "Email: $email"
    echo "Filepath: $HOME/.ssh/id_rsa_$name"
}
