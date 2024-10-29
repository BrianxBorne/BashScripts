#!/bin/bash

check_commits() {
    REPO_NAME=$(basename "$PWD")
    LATEST_COMMIT=$(curl -s "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/commits" | jq -r '.[0].sha')
    
    
    if [ $? -ne 0 ]; then
        echo -e "\nERROR: FAILED TO FETCH THE LATEST COMMIT FROM GITHUB."
        echo -e "PLEASE CHECK YOUR INTERNET CONNECTION OR VERIFY YOUR GITHUB USERNAME.\n"
        exit 1
    fi

    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" = "$LOCAL_COMMIT" ]; then
        echo -e "\nCOMMITS ARE UP TO DATE ON GITHUB.\n"
    else
        echo -e "\nRAPTOR HAS PUSHED NEW COMMITS TO GITHUB.\n"
    fi
}

commit_changes() {
    echo -e "\n~COMMITTING FILES...\n"
    git add .

    
    if [ $? -ne 0 ]; then
        echo -e "\nERROR: FAILED TO STAGE CHANGES."
        echo -e "TRY RUNNING: git add .\n"
        exit 1
    fi

    git commit -m "$commit_message"
    
   
    if [ $? -ne 0 ]; then
        echo -e "\nERROR: COMMIT FAILED. PLEASE CHECK FOR ERRORS."
        echo -e "MAKE SURE YOU HAVE CHANGES STAGED TO COMMIT."
        echo -e "TRY RUNNING: git commit -m \"YOUR COMMIT MESSAGE\"\n"
        exit 1
    fi

    git push origin main
    
   
    if [ $? -ne 0 ]; then
        echo -e "\nERROR: FAILED TO PUSH CHANGES TO GITHUB."
        echo -e "MAKE SURE YOU HAVE PERMISSION TO PUSH TO THE REPOSITORY AND THAT THE REMOTE IS SET UP CORRECTLY."
        echo -e "TRY RUNNING: git push origin main\n"
        exit 1
    fi
}

echo -e "\n~BORNE RAPTOR VERSION 1.1\n"


if ! command -v jq &> /dev/null; then
    echo -e "\nERROR: jq IS NOT INSTALLED. PLEASE INSTALL jq TO CONTINUE."
    echo -e "ON UBUNTU/DEBIAN, YOU CAN INSTALL IT USING: sudo apt-get install jq"
    echo -e "ON MACOS, USE: brew install jq\n"
    exit 1
fi

read -p "ENTER YOUR GITHUB USERNAME: " GITHUB_USERNAME


if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "\nERROR: NOT A VALID GIT REPOSITORY. PLEASE NAVIGATE TO A GIT REPOSITORY."
    echo -e "MAKE SURE YOU'RE IN THE CORRECT DIRECTORY.\n"
    exit 1
fi

if ! git diff-index --quiet HEAD --; then
    echo -e "\nRAPTOR HAS DETECTED CHANGES IN THE REPOSITORY.\n"
    read -p "ENTER YOUR COMMIT MESSAGE: " commit_message
    commit_changes
    check_commits

    
    COMMITTED_FILES=$(git diff --name-only HEAD~1 HEAD)

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
 ~BORNE BASHSCRIPTS~      .--'   /            ._/' >
                        .'   _.-'
                       / .--'
                      /,/
                      |/`)
                      'c=,
EOF

   
    if [ -z "$COMMITTED_FILES" ]; then
        echo -e "\nNO FILES WERE COMMITTED.\n"
    else
        echo -e "FILE:[$COMMITTED_FILES]\nCOMMITTED TO REPOSITORY [$REPO_NAME]\nAT [$GITHUB_USERNAME]\n"
    fi
else
    echo -e "\nRAPTOR HAS FOUND NO CHANGES MADE IN THE REPOSITORY.\n"
fi
