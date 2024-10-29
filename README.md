BashScripts Repository
Overview
This repository contains useful Bash scripts for managing Git repositories. It includes:

commit.sh: A script designed to automate commits to a GitHub repository while securely managing authentication tokens.
viewer.sh: A script that allows users to view the tree layout of directories and files within a specified path.
Features
commit.sh
Secure Token Management: Encrypts your GitHub token for secure storage and decrypts it when needed.
Change Detection: Automatically checks for changes in the local repository before prompting for user input.
Commit and Push: Simplifies the commit and push process with a single command.
Customizable Commit Messages: Allows you to specify a commit message for each run.
Automatic Cleanup: Removes the .gitignore file if it exists to prevent sensitive information from being committed.
viewer.sh
Directory Tree Visualization: Displays a tree-like structure of files and directories to easily navigate and understand the repository layout.
Requirements
Bash
Git
OpenSSL
jq for JSON parsing
Installation
Clone the repository:

git clone https://github.com/YourUsername/BashScripts.git

Navigate to the script directory:

cd BashScripts

Ensure the scripts have execution permissions:

chmod +x commit.sh viewer.sh

Usage
commit.sh
Navigate to your Git repository (if not already done).

Run the script:

./commit.sh

Follow the prompts to enter your GitHub username and token. If you have already saved your token, it will be used automatically.

Specify a commit message when prompted.

The script will commit any changes and push them to your GitHub repository.

viewer.sh
To view the directory and file layout, run:

./viewer.sh [path]

Replace [path] with the directory you want to visualize. If no path is provided, it will default to the current directory.

Important Notes
The commit.sh script will automatically delete any existing .gitignore file in the repository directory to prevent it from being committed.
Keep your encryption password secure, as it is used to encrypt and decrypt your GitHub token.
License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Thanks to OpenSSL for providing encryption tools.
Thanks to jq for helping with JSON parsing in the script.
