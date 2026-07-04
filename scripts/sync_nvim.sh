#!/bin/bash
set -e


if [ -z "$1" ]; then
    echo "Usage: $0 /full/path/to/source/nvim"
    exit 1
fi

SOURCE_PATH="$1"
DEST_PATH="$HOME/.config/nvim"

if [ ! -d "$SOURCE_PATH" ]; then
    echo "Error: Source path '$SOURCE_PATH' does not exist or is not a dir"
    exit 1
fi

if [ -e "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then
    echo "Removing existing ~/.config/nvim"
    rm -rf "$DEST_PATH"
fi

mkdir -p "$HOME/.config"

ln -s "$SOURCE_PATH" "$DEST_PATH"

echo "Symlink created: $DEST_PATH -> $SOURCE_PATH"
