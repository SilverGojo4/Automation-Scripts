#!/bin/bash
# Test script for backup_conda_env.sh

# Input Validation
if [ $# -lt 1 ]; then
	echo "Usage: $0 <conda_env_name>"
	exit 1
fi

# Variable Assignment
TEST_ENV_NAME=$1
OUTPUT_PATH=~/test_environment.yml

# Running backup_conda_env.sh script
echo "Running backup_conda_env.sh for environment '$TEST_ENV_NAME'..."
bash ~/Automation-Scripts/scripts/env/backup_conda_env.sh "$TEST_ENV_NAME" "$OUTPUT_PATH"

# Verifying output file creation
echo "Verifying environment.yml file creation..."
if [ -f "$OUTPUT_PATH" ]; then
	echo "File exists: $OUTPUT_PATH"
else
	echo "Error: Backup file not created - $OUTPUT_PATH"
	exit 1
fi

# Checking if the environment.yml file is not empty
echo "Verifying environment.yml file content..."
if [ -s "$OUTPUT_PATH" ]; then
	echo "Backup file contains data: $OUTPUT_PATH"
else
	echo "Error: Backup file is empty - $OUTPUT_PATH"
	exit 1
fi

# Completion Message
echo "All tests passed successfully for backup_conda_env.sh!"

# Cleanup
rm -f "$OUTPUT_PATH"
