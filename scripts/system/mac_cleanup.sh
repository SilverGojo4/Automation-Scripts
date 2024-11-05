#!/bin/bash
#
# This script cleans up various user cache and log directories on a macOS system.
#
# To make this script easily accessible via a simple command, you can add an alias in your shell's rc file.
# For Zsh: add 'alias cleanup="bash ~/Automation-Scripts/scripts/system/mac_cleanup.sh"' to your .zshrc
#
# Usage: cleanup

# Clear user caches
if [ -d ~/Library/Caches ] && [ "$(ls -A ~/Library/Caches | grep -v '.DS_Store')" ]; then
	find ~/Library/Caches -mindepth 1 ! -name '.DS_Store' -exec rm -rf {} +
	echo "Cleared Path(~/Library/Caches)"
else
	echo "Path(~/Library/Caches) is already empty."
fi

# Empty the Trash
if [ -d ~/.Trash ] && [ "$(ls -A ~/.Trash | grep -v '.DS_Store')" ]; then
	find ~/.Trash -mindepth 1 ! -name '.DS_Store' -exec rm -rf {} +
	echo "Cleared Path(~/.Trash)"
else
	echo "Path(~/.Trash) is already empty."
fi

# Clear user log files
if [ -d ~/Library/Logs ] && [ "$(ls -A ~/Library/Logs | grep -v '.DS_Store')" ]; then
	find ~/Library/Logs -mindepth 1 ! -name '.DS_Store' -exec rm -rf {} +
	echo "Cleared Path(~/Library/Logs)"
else
	echo "Path(~/Library/Logs) is already empty."
fi

# Clear user .cache
if [ -d ~/.cache ] && [ "$(ls -A ~/.cache | grep -v '.DS_Store')" ]; then
	find ~/.cache -mindepth 1 ! -name '.DS_Store' -exec rm -rf {} +
	echo "Cleared Path(~/.cache)"
else
	echo "Path(~/.cache) is already empty."
fi

# Completion Message
echo "Cleanup is complete for $(date +"%Y-%m-%d %H:%M:%S")"

# Exit Status
exit 0
