#!/bin/bash
if ! command -v tree &> /dev/null; then
    echo "The 'tree' command is not installed. Installing..."
    # For Debian/Ubuntu
    sudo apt-get install tree -y
fi

cd ~ || exit
tree
