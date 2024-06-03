#!/bin/bash

short_opts=""
long_opts=""
usage_text=()
action_text=()
actions=()

add_option() {
    local short=$1
    local long=$2
    local description=$3
    local file=$4
    local func=$5

    # Add short option with or without argument handling
    if [[ $short == *":" ]]; then
        short_opts+="${short}"
    else
        short_opts+="${short%:}"
    fi
    
    # Add long option with or without argument handling
    if [[ $long == *":" ]]; then
        long_opts+="${long},"
    else
        long_opts+="${long%:},"
    fi
    
    # Add to usage text
    local help_text=""
    if [[ $short == "" ]]; then
        help_text="[$long] - $description"
    elif [[ $long == "" ]]; then
        help_text="[$short] - $description"
    else
        help_text="[$short, $long] - $description"
    fi

    usage_text+=("$help_text")
    if [[ -z "$file" ]]; then
        actions+=("./scripts/.blank.sh $func")
    else
        actions+=("./scripts/$file $func")
    fi
    
    if [[ $short == "" ]]; then
        action_text+=(", $long")
    elif [[ $long == "" ]]; then
        action_text+=("$short ,")
    else
        action_text+=("$short $long")
    fi    
}

usage() {
    echo "Usage: $0 [options]"
    for item in "${usage_text[@]}"; do
        echo "  $item"
    done
    exit 1
}

process_options() {
    # Ensure short_opts and long_opts are properly formed for getopt
    opts=$(getopt -o "${short_opts}" --long "${long_opts%,}" -- "$@")
    if [[ $? -ne 0 ]]; then
        usage
        exit 1
    fi

    eval set -- "$opts"

    while true; do
        case "$1" in
            --)
                shift
                break
                ;;
            *)
                for i in "${!action_text[@]}"; do
                    short=$(echo "${action_text[$i]}" | awk '{print $1}')
                    long=$(echo "${action_text[$i]}" | awk '{print $2}')
                    if [[ "$1" == "-${short:0:1}" || "$1" == "--${long}" ]]; then
                        file_func="${actions[$i]}"
                        file=$(echo $file_func | awk '{print $1}')
                        func=$(echo $file_func | awk '{print $2}')
                        if [[ -n "$file" && "$file" != "" ]]; then
                            source "$(dirname "$0")/$file"
                        fi
                        if [[ "$2" != "" && "$2" != "--" && "$2" != "-"* ]]; then
                            eval "$func $2"
                            shift 2
                        else
                            eval "$func"
                            shift
                        fi
                        break 2
                    fi
                done
                ;;
        esac
    done
}

# Add options here
add_option "h" "help" "Help Menu" "" "usage"
add_option "" "hi" "Says hello, test command" "hello.sh" "say_hello"
add_option "n" "nvim-sync" "Sets up nvim symlink" "nvim.sh" "nvim_symlink"
add_option "g" "git-ssh-keygen" "Generates a git SSH key and adds to agent" "git.sh" "generate_ssh_key" 

if [[ $# -eq 0 ]]; then
    usage
fi

# Process options and perform actions
process_options "$@"
