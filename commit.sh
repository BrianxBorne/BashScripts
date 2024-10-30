#!/bin/bash

# Function to check if required tools are installed
check_dependencies() {
    command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is not installed. Exiting."; exit 1; }
    command -v openssl >/dev/null 2>&1 || { echo "ERROR: openssl is not installed. Exiting."; exit 1; }
}

# Function to check for the latest commits on GitHub
check_commits() {
    REPO_NAME=$(basename "$PWD")
    LATEST_COMMIT=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/commits" | jq -r '.[0].sha')
    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo "COMMITS ARE UP TO DATE ON GITHUB."
    else
        echo "RAPTOR HAS PUSHED NEW COMMITS TO GITHUB."
    fi
}

# Function to commit changes to the repository
commit_changes() {
    echo "~RAPTOR COMMITTING FILES..."
    git add .
    git commit -m "$commit_message" || { echo "ERROR: Commit failed."; exit 1; }
    git push origin main || { echo "ERROR: Push failed."; exit 1; }
}

# Function to encrypt the GitHub token
encrypt_token() {
    echo -n "$1" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -out .github_token -pass pass:"$ENCRYPTION_PASS"
}

# Function to decrypt the GitHub token
decrypt_token() {
    if [ -f .github_token ]; then
        GITHUB_TOKEN=$(openssl enc -d -aes-256-cbc -in .github_token -pbkdf2 -pass pass:"$ENCRYPTION_PASS" 2>/dev/null)
        if [ $? -ne 0 ] || [ -z "$GITHUB_TOKEN" ]; then
            echo "ERROR: Failed to decrypt the token. It may be corrupted or the wrong password was used."
            exit 1
        fi
    else
        echo "No token file found, prompting for token."
        GITHUB_TOKEN=""
    fi
}

# Function to remove the .gitignore file with confirmation
remove_gitignore() {
    if [ -f .gitignore ]; then
        read -p "Are you sure you want to remove .gitignore? (y/n) " -n 1 -r
        echo    # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f .gitignore
            echo ".gitignore removed."
        else
            echo ".gitignore not removed."
        fi
    fi
}

# Main script starts here
echo "~ BORNE RAPTOR VERSION 1.1"
check_dependencies

# Check if there are changes in the repository
if ! git diff-index --quiet HEAD -- || git ls-files --others --exclude-standard --error-unmatch "$TARGET_DIR" >/dev/null 2>&1; then
    echo "RAPTOR HAS DETECTED CHANGES IN THE REPOSITORY."
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
    exit 0
fi

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME
remove_gitignore

# Remove the cached token if it exists
if git ls-files --error-unmatch .github_token >/dev/null 2>&1; then
    git rm --cached .github_token
fi

# Decrypt the GitHub token
decrypt_token

# If the token could not be decrypted, prompt for it
if [ -z "$GITHUB_TOKEN" ]; then
    read -s -p "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"
    else
        echo "ERROR: No token entered. Exiting Raptor."
        exit 1
    fi
fi

TARGET_DIR="${1:-.}"

# Change to the specified target directory
if ! cd "$TARGET_DIR"; then
    echo "ERROR: RAPTOR COULD NOT CHANGE TO DIRECTORY [$TARGET_DIR]."
    echo "PLEASE CHECK IF THE DIRECTORY EXISTS."
    exit 1
fi

read -p "ENTER YOUR COMMIT MESSAGE: " commit_message
commit_changes
check_commits

COMMITTED_FILES=$(git diff --name-only HEAD^ HEAD)

cat << "EOF"
                           ~ THE BORNE RAPTOR ~
~GitHub Commit Bash Script~                          ___._ 
~Raptor Version  2.3 ~                             .'  <0>'-.._
~Author: BrianxBorne on GITHUB                    /  /.--.____")
~File: 'commit.sh' in Public Repo BashScripts     |   \   __.-'~ 
~Follow Me ~brian_x_borne~ On X                  |  :  -'/ 
~Email: brianxborne@gmail.com                   /:.  :.-' 
__________                                     | : '. | 
'--.____  '--------.______       _.----.-----./      :/ 
        '--.__            `'----/       '-.      __ :/ 
              '-.___           :           \   .'  )/ 
                    '---._           _.-'   ] /  _/ 
                             \_ .-'____.-'__< |  \___ 
                              <_______.\    \_\_---.7 
                              |   /'=r_.-'     _\\ =/ 
                           .--'   /            ._/' > 
                        .'   _.-' 
                       / .--' 
                      /,/ 
                      |/`) 
                      'c=, 
EOF

# Display committed files if any
if [ -n "$COMMITTED_FILES" ]; then
    echo -e "FILE(S):\n$COMMITTED_FILES\nCOMMITTED TO REPOSITORY: [$REPO_NAME]\nAT: [$GITHUB_USERNAME]\n"
fi
