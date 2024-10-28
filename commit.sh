#!/bin/bash

# Display the initial calling message
echo "~Calling Borne Raptor..."

# Display the version message
echo "~Borne Raptor Version1.1"

# Prompt for the commit message
read -p "Enter your commit message: " COMMIT_MESSAGE

# Check if the commit message is empty
if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Error: Commit message cannot be empty."
    exit 1
fi

# Stage all changes
git add .

# Commit the changes with the provided message
git commit -m "$COMMIT_MESSAGE"

# Check if the commit was successful
if [ $? -eq 0 ]; then
    # Push the changes to the main branch
    git push origin main

    # Check if the push was successful
    if [ $? -eq 0 ]; then
        # Get the list of files that were committed
        FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

        # Get the current repository URL and extract the repo name and account
        REPO_URL=$(git config --get remote.origin.url)
        
        if [[ $REPO_URL == *"github.com"* ]]; then
            # Extract GitHub account and repository name from URL
            REPO_NAME=$(basename -s .git "$REPO_URL")
            GITHUB_ACCOUNT=$(basename "$(dirname "$REPO_URL")")
        else
            REPO_NAME="unknown_repo"
            GITHUB_ACCOUNT="unknown_account"
        fi

        # Display the ASCII art
        cat << "EOF"
                                                     ___._
                                                   .'  <0>'-.._
                                                  /  /.--.____")
                                                 |   \   __.-'~
                                                 |  :  -'/ 
                                                /:.  :.-'
__________                                     | : '. |
'--.____  '--------.______       _.----.-----./      :/
        '--.__            `'----/       '-.      __ :/
              '-.___           :           \   .'  )/
                    '---._           _.-'   ] /  _/
 ~Commiting Files...     '-._      _/     _/ / _/
 ~Commit Success.             \_ .-'____.-'__< |  \___
                               <_______.\    \_\_---.7
                              |   /'=r_.-'     _\\ =/
 ~Borne BashScripts~      .--'   /            ._/' >
                        .'   _.-'
                       / .--'
                      /,/
                      |/`)
                      'c=,
EOF

        # Display the commit details with square brackets
        echo "File [$FILES] committed to Repository [$REPO_NAME] at [$GITHUB_ACCOUNT]"
    else
        echo "Error: Push failed."
        exit 1
    fi
else
    echo "Error: Commit failed."
    exit 1
fi
