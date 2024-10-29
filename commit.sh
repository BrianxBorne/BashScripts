#!/bin/bash

# Check for required tools
for cmd in curl jq git openssl; do
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
    LATEST_COMMIT=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USERNAME/commits" | jq -r '.[0].sha')
    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo "COMMITS ARE UP TO DATE ON GITHUB."
    else
        echo "RAPTOR HAS PUSHED NEW COMMIT TO GITHUB."
    fi
}

commit_changes() {
    echo "~ COMMITTING FILES..."
    git add .
    git commit -m "$commit_message" || { echo "ERROR: Commit failed."; exit 1; }
    git push origin "$CURRENT_BRANCH"
    if [ $? -ne 0 ]; then
        echo "ERROR: Push failed. Please check your GitHub username, token, and remote repository settings."
        exit 1
    fi
    COMMITTED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)
}

encrypt_token() {
    echo "$1" | openssl enc -aes-256-cbc -salt -a -pass pass:"$ENCRYPTION_PASSWORD" -out .github_token
}

decrypt_token() {
    if [ -f .github_token ]; then
        DECRYPTED_TOKEN=$(openssl enc -aes-256-cbc -d -a -pass pass:"$ENCRYPTION_PASSWORD" -in .github_token)
        echo "$DECRYPTED_TOKEN"
    else
        echo ""
    fi
}

initialize_gitignore() {
    if [ ! -f .gitignore ]; then
        touch .gitignore
    fi

    if ! grep -q ".github_token" .gitignore; then
        echo ".github_token" >> .gitignore
    fi
}

echo "~ BORNE RAPTOR VERSION 1.1"

# Set the encryption password
ENCRYPTION_PASSWORD="your_secure_password_here"  # Change this to a secure password

# Initialize .gitignore
initialize_gitignore

# Load stored username and token if available
stored_username=$(decrypt_token | cut -d ':' -f 1)
stored_token=$(decrypt_token | cut -d ':' -f 2)

# Loop until a valid GitHub username is provided
while true; do
    read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME

    if [ -z "$GITHUB_USERNAME" ]; then
        echo "ERROR: GitHub username cannot be empty."
        continue
    fi
    
    # Check if the GitHub username exists
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://api.github.com/users/$GITHUB_USERNAME")
    
    if [ "$RESPONSE_CODE" -eq 200 ]; then
        echo "GitHub username verified."
        break
    else
        echo "ERROR: The GitHub username '$GITHUB_USERNAME' does not exist. Please try again."
    fi
done

# If the stored username matches the input, use the stored token
if [[ "$GITHUB_USERNAME" == "$stored_username" ]]; then
    GITHUB_TOKEN="$stored_token"
    echo "Using stored token for username: $GITHUB_USERNAME."
else
    # Loop until a valid GitHub token is provided
    while true; do
        read -sp "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
        echo

        if [ -z "$GITHUB_TOKEN" ]; then
            echo "ERROR: GitHub token cannot be empty."
            continue
        fi

        # Validate the token against the GitHub API for the username
        TOKEN_RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user")

        if [ "$TOKEN_RESPONSE_CODE" -eq 200 ]; then
            # Check if the username matches the token owner
            USERNAME_FROM_TOKEN=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user" | jq -r '.login')
            if [ "$USERNAME_FROM_TOKEN" == "$GITHUB_USERNAME" ]; then
                echo "GitHub token verified for username: $GITHUB_USERNAME."
                encrypt_token "$GITHUB_USERNAME:$GITHUB_TOKEN"
                break
            else
                echo "ERROR: The provided token does not belong to the username '$GITHUB_USERNAME'."
            fi
        else
            echo "ERROR: Invalid GitHub token. Authorization failed."
        fi
    done
fi

# Resolve the target directory
TARGET_DIR="${1:-.}"

# Check if provided directory exists; if not, try $HOME
if [ ! -d "$TARGET_DIR" ]; then
    TARGET_DIR="$HOME/$TARGET_DIR"
    if [ ! -d "$TARGET_DIR" ]; then
        echo "ERROR: Could not locate directory [$1] in the current or home directories."
        exit 1
    fi
fi

# Change to target directory
if ! cd "$TARGET_DIR"; then
    echo "ERROR: Could not change to directory [$TARGET_DIR]. Please check if the directory exists."
    exit 1
fi

# Check if the token is valid and print a message about the token's status
TOKEN_VALIDATION=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/rate_limit")
TOKEN_EXPIRED=false

if [[ $(echo "$TOKEN_VALIDATION" | jq '.rate.reset') -lt $(date +%s) ]]; then
    TOKEN_EXPIRED=true
    echo "WARNING: The provided token is expired."
else
    echo "Token is valid. The deadline of the token will need to be managed manually."
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
