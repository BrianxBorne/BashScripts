#!/bin/bash

# Check if the tree command is installed
if ! command -v tree &> /dev/null; then
    echo "The 'tree' command is not installed. Installing..."
    # For Debian/Ubuntu
    sudo apt-get install tree -y
    # For Red Hat/Fedora
    # sudo dnf install tree -y
    # For macOS (using Homebrew)
    # brew install tree
fi

# Change to the home directory
cd ~ || exit

# Display the tree structure
tree
