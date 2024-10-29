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
    git push origin main
}

encrypt_token() {
    echo -n "$1" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -out .github_token -pass pass:"$ENCRYPTION_PASS"
}

decrypt_token() {
    if [ -f .github_token ]; then
        GITHUB_TOKEN=$(openssl enc -d -aes-256-cbc -in .github_token -pbkdf2 -pass pass:"$ENCRYPTION_PASS")
    else
        GITHUB_TOKEN=""
    fi
}

setup_gitignore() {
    if [ ! -f .gitignore ]; then
        touch .gitignore
    fi
    if ! grep -q ".github_token" .gitignore; then
        echo ".github_token" >> .gitignore
    fi
}

# Main script starts here
echo "~ BORNE RAPTOR VERSION 1.1"

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME

# Check if token file exists and decrypt it
setup_gitignore
decrypt_token

# Check if token is valid
if [ -z "$GITHUB_TOKEN" ]; then
    read -p "ENTER YOUR GITHUB TOKEN (leave blank to skip authorization check): " GITHUB_TOKEN
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"
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

    if [ -z "$COMMITTED_FILES" ]; then
        echo -e "\nNO FILES WERE COMMITTED.\n"
    else
        echo -e "FILE(S):\n$COMMITTED_FILES\nCOMMITTED TO REPOSITORY: [$REPO_NAME]\nAT: [$GITHUB_USERNAME]\n"
    fi
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
fi
