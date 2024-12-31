#!/bin/bash
#
# This script creates a .vscode folder with a settings.json file in the specified project path.
#
# Usage: create_vscode_config.sh <project_directory>
#
# To make this script easily accessible, you can add a function in your shell's rc file.
# For Zsh: add the following to your .zshrc file:
# createvscode() {
#     if [ $# -lt 1 ]; then
#         echo "Usage: createvscode <project_directory>"
#         return 1
#     fi
#     bash ~/Automation-Scripts/scripts/vscode/create_vscode_config.sh "$1"
# }
#
# Example usage:
# createvscode /path/to/your/project

# Input Validation
if [ $# -lt 1 ]; then
	echo "Usage: $0 <project_directory>"
	exit 1
fi

# Variable Assignment
target_path=$1
vscode_path="$target_path/.vscode"
settings_file="$vscode_path/settings.json"
settings_json='{
  // Font and interface display settings
  "editor.fontSize": 12,
  "editor.fontFamily": "Monaco",
  "editor.wordWrap": "on",

  // Code writing and formatting settings
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "editor.parameterHints.enabled": true,

  // File saving and auto-save settings
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 5000,

  // File and editor behavior settings
  "files.encoding": "utf8",
  "editor.renderLineHighlight": "all",

  // Version control settings
  "git.autofetch": true,

  // Advanced code assistance settings
  "path-intellisense.extensionOnImport": true,
  "editor.tabCompletion": "on",
  "javascript.suggest.autoImports": true,
  "typescript.suggest.autoImports": true,

  // Syntax checking settings
  "javascript.validate.enable": true,
  "typescript.validate.enable": true,
  "css.validate": true,
  "html.validate.scripts": true,
  "html.validate.styles": true,
  "json.validate.enable": true,

  // Additional advanced code assistance settings
  "editor.bracketPairColorization.enabled": true,

  // Python configuration
  "python.analysis.autoImportCompletions": true,
  "python.terminal.activateEnvironment": true,

  // Specify additional Python module search paths
  "python.analysis.extraPaths": ["path"],

  // Python language-specific settings
  "[python]": {
    "diffEditor.ignoreTrimWhitespace": false,
    "editor.formatOnType": true,
    "editor.wordBasedSuggestions": "off",
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },

  // Python analysis and type checking
  "python.analysis.typeCheckingMode": "basic",
  "python.analysis.completeFunctionParens": true,

  // isort configuration
  "isort.args": ["--profile", "black"],

  // Prettier settings
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },

  // Live Server settings
  "liveServer.settings.AdvanceCustomBrowserCmdLine": "chrome",
  "liveServer.settings.port": 5500,
  "liveServer.settings.NoBrowser": false,
  "liveServer.settings.fullReload": true
}'

# Error Handling: Check if the target directory exists
if [ ! -d "$target_path" ]; then
	echo "Error: $target_path does not exist."
	exit 1
fi

# Function to prompt the user for confirmation
prompt_user() {
	local prompt_message=$1

	echo "$prompt_message"
	read -p "Proceed ([y]/n)? " proceed # 使用 -p 選項，直接在 read 中顯示提示訊息
	if [[ "$proceed" == "y" || "$proceed" == "Y" ]]; then
		return 0
	fi
	return 1
}

# Core Logic: Create the .vscode directory
create_vscode_config() {

	# Create the .vscode directory if it doesn't exist
	mkdir -p "$vscode_path"

	if [ -f "$settings_file" ]; then

		# Optional: Prompt the user to confirm overwriting the existing settings.json file
		if ! prompt_user "$settings_file already exists. Do you want to overwrite it?"; then
			exit 0
		fi
	fi

	echo "$settings_json" >"$settings_file"
}

# Optional: Case-Sensitive Directory Check
if ! prompt_user "Please check if a directory with a similar name (but different case) already exists."; then
	exit 1
fi

# Call the function
create_vscode_config

# Completion Message
echo "$settings_file setup is complete for $(date +"%Y-%m-%d %H:%M:%S")"

# Exit Status
exit 0
