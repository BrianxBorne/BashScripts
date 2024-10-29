#!/bin/bash

check_commits() {
    REPO_NAME=$(basename "$PWD")
    LATEST_COMMIT=$(curl -s "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME/commits" | jq -r '.[0].sha')
    LOCAL_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" == "$LOCAL_COMMIT" ]; then
        echo "Commits are up to date on GitHub."
    else
        echo "New commits have been pushed to GitHub!"
    fi
}

commit_changes() {
    echo "~Commiting Files..."
    git add .
    git commit -m "$commit_message"
    git push origin main
}

echo "~Calling Borne Raptor..."
echo "~Borne Raptor Version1.1"

read -p "Enter your GitHub username: " GITHUB_USERNAME

if ! git diff-index --quiet HEAD --; then
    echo "Changes detected in the repository."
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
    echo "No changes made in the repository."
fi
