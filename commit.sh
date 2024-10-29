#!/bin/bash

check_commits() {
    REPO_NAME=$(basename "$PWD")
    LATEST_COMMIT=$(curl -s "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/commits" | jq -r '.[0].sha')
    
    # Check if the API call was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch the latest commit from GitHub."
        echo "Please check your internet connection or verify your GitHub username."
        exit 1
    fi

    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" = "$LOCAL_COMMIT" ]; then
        echo "Commits are up to date on GitHub."
    else
        echo "Raptor has pushed new commits to GitHub."
    fi
}

commit_changes() {
    echo "~Committing Files..."
    git add .

    # Check if 'git add' was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to stage changes."
        echo "Try running: git add ."
        exit 1
    fi

    git commit -m "$commit_message"
    
    # Check if the commit was successful
    if [ $? -ne 0 ]; then
        echo "Error: Commit failed. Please check for errors."
        echo "Make sure you have changes staged to commit."
        echo "Try running: git commit -m \"your commit message\""
        exit 1
    fi

    git push origin main
    
    # Check if the push was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to push changes to GitHub."
        echo "Make sure you have permission to push to the repository and that the remote is set up correctly."
        echo "Try running: git push origin main"
        exit 1
    fi
}

echo "~Borne Raptor Version 1.1"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to continue."
    echo "On Ubuntu/Debian, you can install it using: sudo apt-get install jq"
    echo "On macOS, use: brew install jq"
    exit 1
fi

read -p "Enter your GitHub username: " GITHUB_USERNAME

# Check if we are in a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not a valid Git repository. Please navigate to a Git repository."
    echo "Make sure you're in the correct directory."
    exit 1
fi

if ! git diff-index --quiet HEAD --; then
    echo "Raptor has detected changes in the repository."
    read -p "Enter your commit message: " commit_message
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

    echo -e "File [$COMMITTED_FILES] committed to Repository [$REPO_NAME] at [$GITHUB_USERNAME].\n"
else
    echo "Raptor has found no changes made in the repository."
fi
