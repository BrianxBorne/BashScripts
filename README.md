# BashScripts

Welcome to the **BashScripts** repository! This repository contains a collection of Bash scripts designed to streamline various tasks.

## Files Included

1. **commit.sh**: This script facilitates the process of committing changes to a GitHub repository. It prompts the user for their GitHub username and token, verifies the credentials, and commits any changes detected in the local repository. If the token is successfully encrypted, it will be stored securely for future use. The script ensures that sensitive information, such as the GitHub token, is handled securely.

2. **viewer.sh**: This script allows users to view the tree layout of directories and files in a specified location. It provides a clear visual representation of the file structure, making it easier to navigate and understand the organization of files.

## Features

- **Secure Token Management**: The `commit.sh` script encrypts and securely stores the GitHub token to prevent unauthorized access.
- **Automatic Change Detection**: Before prompting for user input, the script checks if there are changes in the repository, ensuring that only relevant changes are committed.
- **User-Friendly Prompts**: The scripts guide the user through each step with clear prompts and feedback messages.

## Usage

To use the scripts, clone the repository to your local machine:

```bash
git clone https://github.com/BrianxBorne/BashScripts.git
cd BashScripts
```

### Running commit.sh

To run the `commit.sh` script, use the following command:

```bash
./commit.sh
```

### Running viewer.sh

To view the directory tree structure, use the following command:

```bash
./viewer.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Special thanks to the open-source community for their contributions and support in developing these scripts.
