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
            echo "ERROR:Raptor failed to decrypt the token. It may be corrupted or the wrong password was used."
            return 1
        fi
    else
        GITHUB_TOKEN=""
    fi
    return 0
}

remove_gitignore() {
    if [ -f .gitignore ]; then
        rm -f .gitignore
    fi
}

echo "~ BORNE RAPTOR VERSION 1.1"

if ! git diff-index --quiet HEAD -- || git ls-files --others --exclude-standard --error-unmatch "$TARGET_DIR" >/dev/null 2>&1; then
    echo "RAPTOR HAS DETECTED CHANGES IN THE REPOSITORY."
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
    exit 0
fi

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME

remove_gitignore

if git ls-files --error-unmatch .github_token >/dev/null 2>&1; then
    git rm --cached .github_token
fi

decrypt_token

if [ $? -ne 0 ]; then
    read -s -p "ENTER YOUR GITHUB TOKEN: " GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
        encrypt_token "$GITHUB_TOKEN"
    else
        echo "ERROR: No Token Entered. Exiting Raptor."
        exit 1
    fi
fi

TARGET_DIR="${1:-.}"

if ! cd "$TARGET_DIR"; then
    echo "ERROR: RAPTOR COULD NOT CHANGE TO DIRECTORY [$TARGET_DIR]."
    echo "PLEASE CHECK IF THE DIRECTORY EXISTS."
    exit 1
fi

if ! git pull origin main --no-rebase; then
    echo "ERROR: Failed to pull latest changes. Please resolve any conflicts."
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
