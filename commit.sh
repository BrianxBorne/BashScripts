#!/bin/bash

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

commit_changes() {
    echo "~ COMMITTING FILES..."
    git add .
    git commit -m "$commit_message"
    if [ $? -ne 0 ]; then
        echo "ERROR: Commit failed."
        exit 1
    fi
    git push origin main
}

encrypt_token() {
    echo -n "$1" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -out .github_token -pass pass:"$ENCRYPTION_PASS"
}

decrypt_token() {
    if [ -f .github_token ]; then
        GITHUB_TOKEN=$(openssl enc -d -aes-256-cbc -in .github_token -pbkdf2 -pass pass:"$ENCRYPTION_PASS" 2>/dev/null)
        if [ $? -ne 0 ] || [ -z "$GITHUB_TOKEN" ]; then
            echo "ERROR: Failed to decrypt the token. It may be corrupted or the wrong password was used."
            echo "Please re-enter your GitHub token."
            return 1  # Indicate failure
        fi
    else
        GITHUB_TOKEN=""
    fi
    return 0  # Indicate success
}

setup_gitignore() {
    if [ -f .gitignore ]; then
        rm -f .gitignore  # Delete the .gitignore file if it exists
    fi
}

# Main script starts here
echo "~ BORNE RAPTOR VERSION 1.1"

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME

# Ensure .gitignore is deleted
setup_gitignore

# Check if .github_token is tracked, remove it from tracking if it is
if git ls-files --error-unmatch .github_token >/dev/null 2>&1; then
    git rm --cached .github_token
fi

# Attempt to decrypt the token
decrypt_token

# Check if token was decrypted successfully
if [ $? -ne 0 ]; then
    # Prompt for GitHub token if decryption failed
    read -s -p "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
    echo ""  # Move to the next line after silent input
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"
    else
        echo "ERROR: No token entered. Exiting."
        exit 1
    fi
fi

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

    # List the committed files
    COMMITTED_FILES=$(git diff --name-only HEAD^ HEAD)

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

    # Display the committed files information
    if [ -n "$COMMITTED_FILES" ]; then
        echo -e "FILE(S):\n$COMMITTED_FILES\nCOMMITTED TO REPOSITORY: [$REPO_NAME]\nAT: [$GITHUB_USERNAME]\n"
    else
        echo -e "\nNO FILES WERE COMMITTED.\n"
    fi
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
fi
