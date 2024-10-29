#!/bin/bash

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
    git commit -m "$commit_message"
    git push origin main
}

# Main script starts here
echo "~ BORNE RAPTOR VERSION 1.1"

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME

# Check if a directory argument was provided
TARGET_DIR="${1:-.}" # Use current directory if no argument is given

# Change to the target directory
if ! cd "$TARGET_DIR"; then
    echo "ERROR: COULD NOT CHANGE TO DIRECTORY [$TARGET_DIR]."
    echo "PLEASE CHECK IF THE DIRECTORY EXISTS."
    exit 1
fi

if ! git diff-index --quiet HEAD --; then
    echo "RAPTOR HAS DETECTED CHANGES IN THE REPOSITORY."
    read -p "ENTER YOUR COMMIT MESSAGE: " commit_message
    commit_changes
    check_commits

    COMMITTED_FILES=$(git diff --name-only)

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

    echo -e "FILE [$COMMITTED_FILES] COMMITTED TO REPOSITORY [$REPO_NAME] AT [$GITHUB_USERNAME].\n"
else
    echo "RAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY."
fi
