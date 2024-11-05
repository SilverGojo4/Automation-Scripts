#!/bin/bash
#
# This script backs up a specified Conda environment by exporting its configuration to an environment.yml file.
#
# Usage: backup_conda_env.sh <conda_env_name> <output_path>
#
# To make this script easily accessible via a simple command, you can add a function in your shell's rc file.
# For Bash: add the following to your .bashrc file:
# backupconda() {
#     if [ $# -lt 2 ]; then
#         echo "Usage: backupconda <conda_env_name> <output_path>"
#         return 1
#     fi
#     bash ~/Automation-Scripts/scripts/env/backup_conda_env.sh "$1" "$2"
# }
#
# Example usage:
# backupconda myenv /path/to/save/environment.yml

# Input Validation
if [ $# -lt 2 ]; then
	echo "Usage: $0 <conda_env_name> <output_path>"
	exit 1
fi

# Variable Assignment
conda_env_name=$1
output_path=$2

# Check if the specified Conda environment exists
if ! conda info --envs | grep -q "^$conda_env_name\s"; then
	echo "Error: Conda environment '$conda_env_name' does not exist."
	exit 1
fi

# Export the Conda environment to a YAML file
conda env export -n "$conda_env_name" >"$output_path"

# Check if the export was successful
if [ $? -eq 0 ]; then
	echo "Successfully backed up Conda environment '$conda_env_name' to '$output_path'"
else
	echo "Error: Failed to export Conda environment '$conda_env_name'. Please check the environment name and output path."
	exit 1
fi

# Completion Message
echo "Backup of Conda environment '$conda_env_name' to '$output_path' is complete on $(date +"%Y-%m-%d %H:%M:%S")"

# Exit Status
exit 0
