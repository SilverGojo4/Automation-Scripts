#!/bin/bash
#
# This script creates a project directory with a predefined structure and essential files.
#
# Usage: create_project.sh <project_directory>
#
# To make this script easily accessible, you can add a function in your shell's rc file.
# For Zsh: add the following to your .zshrc file:
# createproject() {
#     if [ $# -lt 1 ]; then
#         echo "Usage: createproject <project_directory>"
#         return 1
#     fi
#     bash ~/Automation-Scripts/scripts/project_setup/create_project.sh "$1"
# }
#
# Example usage:
# createproject /path/to/your/project

# Input Validation
if [ $# -lt 1 ]; then
	echo "Usage: $0 <project_directory>"
	exit 1
fi

# Variable Assignment
directory=$1
gitignore_content='# Ignore files generated by Python compilation
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# Ignore cache directories generated by pytest
.pytest_cache/

# Ignore files generated by Java compilation
*.class
# Directory containing class files
bin/
# Directories generated by package managers (e.g., Maven)
target/

# General ignore rules (log files, editor configurations, etc.)
*.log
*.tmp
*.temp
*.swp
*~
*.DS_Store

# Ignore VSCode personal settings
.vscode/'
readme_content="# My_Project

This is the official codebase for **My_Project**.

(文章連結)[![Preprint](https://img.shields.io/badge/preprint-available-brightgreen)](https://你的文章連結) &nbsp;
(專案文件)[![Documentation](https://img.shields.io/badge/docs-available-brightgreen)](https://你的專案文件連結) &nbsp;
(PyPI 專案)[![PyPI version](https://badge.fury.io/py/你的框架名稱.svg)](https://pypi.org/project/你的框架名稱) &nbsp;
(下載量統計)[![Downloads](https://pepy.tech/badge/你的框架名稱)](https://pepy.tech/project/你的框架名稱) &nbsp;

**[日期]** 新消息內容

## Installation

My_Project works with Python >= python_version and R >= r_version Please make sure you have the correct version of Python and R installed pre-installation.

- (改成代碼區塊) pip install -r requirements.txt

Or with Conda:

- (改成代碼區塊) conda env create -f environment.yml

## Contributing

We greatly welcome contributions to My_Project. Please submit a pull request if you have any ideas or bug fixes. We also welcome any issues you encounter while using My_Project.

## Acknowledgements

We sincerely thank the authors of following open-source projects:

- [開源專案名稱](https://github.com/開源專案連結)
"

# Error Handling: Check if the project directory exists
if [ ! -d "$directory" ]; then
	mkdir -p "$directory"
	echo "Created project $directory"
else
	echo "Error: $directory already exists."
	echo "Please check if a directory with a similar name (but different case) already exists."
	exit 1
fi

# Core Logic: Create the project directory and necessary files
create_project_directory() {

	# Create the project directory structure
	directories=(
		"$directory/data/raw"
		"$directory/data/processed"
		"$directory/data/external"
		"$directory/data/interim"
		"$directory/notebooks/eda"
		"$directory/notebooks/experiments"
		"$directory/src/data"
		"$directory/src/models"
		"$directory/src/evaluation"
		"$directory/src/inference"
		"$directory/src/utils"
		"$directory/logs/data"
		"$directory/logs/models"
		"$directory/logs/evaluation"
		"$directory/logs/inference"
		"$directory/experiments/models"
		"$directory/experiments/results"
		"$directory/experiments/checkpoints"
		"$directory/tests/unit"
		"$directory/tests/integration"
		"$directory/tests/performance"
		"$directory/configs"
		"$directory/scripts"
	)

	for dir in "${directories[@]}"; do
		mkdir -p "$dir"
	done

	# Create .gitignore
	echo "$gitignore_content" >"$directory/.gitignore"
	echo "Created .gitignore"

	# Create requirements.txt
	touch "$directory/requirements.txt"
	echo "Created requirements.txt"

	# Create environment.yml
	touch "$directory/environment.yml"
	echo "Created environment.yml"

	# Create README.md
	echo "$readme_content" >"$directory/README.md"
	echo "Created README.md"
}

# Call the function
create_project_directory

# Completion Message
echo "$directory setup is complete for $(date +"%Y-%m-%d %H:%M:%S")"

# Exit Status
exit 0
