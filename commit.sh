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
    echo "~RAPTOR COMMITTING FILES..."
    git add .

    # Exclude .gitignore from the commit
    git reset .gitignore

    # Check if .github_token is being tracked and ignore it if present
    if git ls-files --error-unmatch .github_token >/dev/null 2>&1; then
        git rm --cached .github_token
    fi

    git commit -m "$commit_message"
    git push origin main
}

encrypt_token() {
    echo -n "$1" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -out .github_token -pass pass:"$ENCRYPTION_PASS"
}

decrypt_token() {
    if [ -f .github_token ]; then
        GITHUB_TOKEN=$(openssl enc -d -aes-256-cbc -in .github_token -pbkdf2 -pass pass:"$ENCRYPTION_PASS" 2>/dev/null)
        if [ $? -ne 0 ] || [ -z "$GITHUB_TOKEN" ]; then
            echo "ERROR: Failed to decrypt the token. Please check your encryption password or the token file."
            return 1
        fi
    else
        GITHUB_TOKEN=""
    fi
    return 0
}

remove_gitignore() {
    if [ -f .gitignore ]; then
        git rm --cached .gitignore  # Untrack .gitignore if it exists
        rm -f .gitignore            # Delete it from the local directory
    fi
}

echo "~ BORNE RAPTOR VERSION 1.1"

if ! git diff-index --quiet HEAD -- || git ls-files --others --exclude-standard --error-unmatch "$TARGET_DIR" >/dev/null 2>&1; then
    echo "RAPTOR HAS DETECTED CHANGES IN THE REPOSITORY."
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
    exit 0
fi

# Check if .github_token exists and try to decrypt
decrypt_token

# Prompt for GitHub username if token is not set or if it changes
read -p "ENTER YOUR GITHUB USERNAME: " NEW_GITHUB_USERNAME

if [ "$GITHUB_USERNAME" != "$NEW_GITHUB_USERNAME" ]; then
    GITHUB_USERNAME="$NEW_GITHUB_USERNAME"
    # If the username changes, prompt for the token
    read -s -p "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"
    else
        echo "ERROR: No token entered. Exiting Raptor."
        exit 1
    fi
else
    # If the username is the same, check if the token was decrypted
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
fi

TARGET_DIR="${1:-.}"

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
~Aurthor:BrianxBorne on GITHUB                    /  /.--.____")
~File:'commit.sh' in Public Repo BashScripts     |   \   __.-'~ 
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

if [ -n "$COMMITTED_FILES" ]; then
    echo -e "FILE(S):\n$COMMITTED_FILES\nCOMMITTED TO REPOSITORY: [$REPO_NAME]\nAT: [$GITHUB_USERNAME]\n"
fi
