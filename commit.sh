#!/bin/bash

# Check for required tools
for cmd in curl jq git; do
    if ! command -v $cmd &> /dev/null; then
        echo "ERROR: Required tool '$cmd' is not installed."
        exit 1
    fi
done

# Check if inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "ERROR: This script must be run inside a Git repository."
    exit 1
fi

# Get the current branch dynamically
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

check_commits() {
    REPO_NAME=$(basename "$PWD")
    LATEST_COMMIT=$(curl -s "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/commits" | jq -r '.[0].sha')
    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo "COMMITS ARE UP TO DATE ON GITHUB."
    else
        echo "RAPTOR HAS PUSHED NEW COMMITS TO GITHUB."
    fi
}

commit_changes() {
    echo "~ COMMITTING FILES..."
    git add .
    git commit -m "$commit_message" || { echo "ERROR: Commit failed."; exit 1; }
    git push origin "$CURRENT_BRANCH" || { echo "ERROR: Push failed. Check your remote repository settings or authentication."; exit 1; }
    COMMITTED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)
}

echo "~ BORNE RAPTOR VERSION 1.1"

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "ERROR: GitHub username cannot be empty."
    exit 1
fi

TARGET_DIR="${1:-.}"

if ! cd "$TARGET_DIR"; then
    echo "ERROR: Could not change to directory [$TARGET_DIR]. Please check if the directory exists."
    exit 1
fi

if ! git diff-index --quiet HEAD --; then
    echo "RAPTOR HAS DETECTED CHANGES IN THE REPOSITORY."

    # Keep prompting for a commit message until it is not empty
    while true; do
        read -p "ENTER YOUR COMMIT MESSAGE: " commit_message
        if [ -n "$commit_message" ]; then
            break
        else
            echo "Commit message cannot be empty. Please enter a valid commit message."
        fi
    done

    commit_changes
    check_commits

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
 ~COMMIT SUCCESS.             \_ .-'____.-'__< |  \___
                               <_______.\    \_\_---.7
                              |   /'=r_.-'     _\\ =/
 ~BORNE BASH SCRIPTS~      .--'   /            ._/' >
                        .'   _.-'
                       / .--'
                      /,/
                      |/`)
                      'c=,
EOF

    if [ -z "$COMMITTED_FILES" ]; then
        echo "NO FILES WERE COMMITTED."
    else
        echo "FILE(S):"
        printf "%s\n" "$COMMITTED_FILES"
        echo "COMMITTED TO REPOSITORY: [$REPO_NAME]"
        echo "AT: [$GITHUB_USERNAME]"
    fi
else
    echo "RAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY."
fi
