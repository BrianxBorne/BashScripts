#!/bin/bash

# Function to check for commits on GitHub
check_commits() {
    # Derive the repository name from the current directory name
    REPO_NAME=$(basename "$PWD")  # Gets the name of the current directory
    LATEST_COMMIT=$(curl -s "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/commits" | jq -r '.[0].sha')
    
    # Get the latest local commit hash
    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo "Commits are up to date on GitHub."
    else
        echo "New commits have been pushed to GitHub!"
    fi
}

# Function to commit local changes
commit_changes() {
    echo "~Commiting Files..."
    git add .
    git commit -m "$commit_message"
    git push origin main
}

# Start of the script
echo "~Calling Borne Raptor..."
echo "~Borne Raptor Version1.1"

# Prompt for GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    # Inform the user that there are changes to commit
    echo "Changes detected in the repository."

    # Enter your commit message
    read -p "Enter your commit message: " commit_message
    commit_changes

    # Check for commits on GitHub after committing
    check_commits

    # Display success message and ASCII art
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
 ~Borne BashScripts~      .--'   /            ._/'>
                        .'   _.-'
                       / .--'
                      /,/
                      |/`)
                      'c=,
EOF

    # Display the commit message
    echo "File [$(git diff --name-only)] committed to Repository [$REPO_NAME] at [$GITHUB_USERNAME]."
else
    # No changes detected
    echo "No changes made in the repository."
fi
