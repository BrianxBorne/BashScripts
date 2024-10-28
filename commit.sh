#!/bin/bash

# Prompt for the commit message
read -p "Enter your commit message: " COMMIT_MESSAGE

# Check if the commit message is empty
if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Error: Commit message cannot be empty."
    exit 1
fi

# Stage all changes
git add .

# Commit the changes with the provided message
git commit -m "$COMMIT_MESSAGE"

# Check if the commit was successful
if [ $? -eq 0 ]; then
    echo "Commit successful!"

    # Display ASCII art
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
                         '-._      _/     _/ / _/
                             \_ .-'____.-'__< |  \___
                               <_______.\    \_\_---.7
                              |   /'=r_.-'     _\\ =/
                          .--'   /            ._/' >
                        .'   _.-'
   Borne               / .--'
                      /,/
                      |/`)
                      'c=,
EOF

    echo "Bash script executed successfully with 0 errors."
else
    echo "Error: Commit failed."
    exit 1
fi

