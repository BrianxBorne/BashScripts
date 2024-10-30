#!/bin/bash

# Function to check for commits in the repository
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

# Function to commit changes
commit_changes() {
    echo "~RAPTOR COMMITTING FILES..."
    git add . 
    git commit -m "$commit_message"
    git push origin main
}

# Function to encrypt the GitHub token
encrypt_token() {
    echo -n "$1" | openssl enc -aes-256-cbc -salt -pbkdf2 -out .github_token -pass pass:"$ENCRYPTION_PASS"
}

# Function to decrypt the GitHub token
decrypt_token() {
    if [ -f .github_token ]; then
        echo "Attempting to decrypt the token..."
        GITHUB_TOKEN=$(openssl enc -d -aes-256-cbc -in .github_token -pbkdf2 -pass pass:"$ENCRYPTION_PASS" 2>/dev/null)

        if [ $? -ne 0 ]; then
            echo "ERROR: Decryption command failed. Check the encryption password."
            return 1
        fi
        
        if [ -z "$GITHUB_TOKEN" ]; then
            echo "ERROR: Decrypted token is empty. The token may be corrupted."
            return 1
        fi

        echo "Token decrypted successfully."
    else
        GITHUB_TOKEN=""
    fi
    return 0
}

# Function to remove .gitignore file
remove_gitignore() {
    if [ -f .gitignore ]; then
        rm -f .gitignore
    fi
}

# Display the script version
echo "~ BORNE RAPTOR VERSION 1.1"

# Check for changes in the repository
if ! git diff-index --quiet HEAD -- || git ls-files --others --exclude-standard --error-unmatch "$TARGET_DIR" >/dev/null 2>&1; then
    echo "RAPTOR HAS DETECTED CHANGES IN THE REPOSITORY."
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
    exit 0
fi

# Read GitHub username
if [ -z "$GITHUB_USERNAME" ]; then
    read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME
else
    echo "Using stored username: $GITHUB_USERNAME"
fi

# Remove .gitignore if it exists
remove_gitignore

# Check if the token file exists, if so, try to decrypt it
decrypt_token
if [ $? -ne 0 ]; then
    # Prompt for GitHub token if decryption fails
    read -s -p "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"  # Encrypt the token
    else
        echo "ERROR: No token entered. Exiting Raptor."
        exit 1
    fi
fi

# Check if the username has changed
read -p "Enter your GitHub username again to confirm: " NEW_USERNAME
if [ "$NEW_USERNAME" != "$GITHUB_USERNAME" ]; then
    GITHUB_USERNAME="$NEW_USERNAME"
    echo "Updated GitHub username."
    read -s -p "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"  # Encrypt the new token
    else
        echo "ERROR: No token entered. Exiting Raptor."
        exit 1
    fi
fi

# Navigate to the target directory (current directory by default)
TARGET_DIR="${1:-.}"

if ! cd "$TARGET_DIR"; then
    echo "ERROR: RAPTOR COULD NOT CHANGE TO DIRECTORY [$TARGET_DIR]."
    echo "PLEASE CHECK IF THE DIRECTORY EXISTS."
    exit 1
fi

# Read the commit message
read -p "ENTER YOUR COMMIT MESSAGE: " commit_message
commit_changes
check_commits

# List the committed files
COMMITTED_FILES=$(git diff --name-only HEAD^ HEAD)

cat << "EOF"
                           ~ THE BORNE RAPTOR ~
~GitHub Commit Bash Script~                          ___._ 
~Raptor Version  1.1 ~                             .'  <0>'-.._
~Author: BrianxBorne on GITHUB                    /  /.--.____")
~File: 'commit.sh' in Public Repo BashScripts     |   \   __.-'~ 
~Follow Me ~brian_x_borne~ On X                  |  :  -'/ 
~Email: brianxborne@gmail.com                    /:.  :.-' 
__________                                      | : '. | 
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

if [ -n "$COMMITTED_FILES" ]; then
    echo -e "FILE(S):\n$COMMITTED_FILES\nCOMMITTED TO REPOSITORY: [$REPO_NAME]\nAT: [$GITHUB_USERNAME]\n"
fi
