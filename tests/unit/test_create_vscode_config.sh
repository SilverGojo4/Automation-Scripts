#!/bin/bash
# Test script for create_vscode_config.sh

# 定義測試目錄
TEST_DIR=~/test_vscode_project

# 確保測試開始前測試目錄不存在（以免干擾測試）
if [ -d "$TEST_DIR/.vscode" ]; then
	rm -rf "$TEST_DIR/.vscode"
fi

# 創建測試目錄
mkdir -p "$TEST_DIR"

# 執行 create_vscode_config.sh 腳本
echo "Running create_vscode_config.sh..."
bash ~/Automation-Scripts/scripts/vscode/create_vscode_config.sh "$TEST_DIR"

# 驗證 .vscode 目錄是否已創建
if [ -d "$TEST_DIR/.vscode" ]; then
	echo ".vscode directory created successfully."
else
	echo "Error: .vscode directory was not created."
	exit 1
fi

# 驗證 settings.json 文件是否已創建
SETTINGS_FILE="$TEST_DIR/.vscode/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
	echo "settings.json file created successfully."
else
	echo "Error: settings.json file was not created."
	exit 1
fi

# 驗證 settings.json 文件是否包含特定設定
echo "Verifying contents of settings.json..."
if grep -q '"editor.fontSize": 12' "$SETTINGS_FILE" &&
	grep -q '"editor.fontFamily": "Monaco"' "$SETTINGS_FILE" &&
	grep -q '"files.autoSave": "afterDelay"' "$SETTINGS_FILE"; then
	echo "settings.json file contains expected configuration."
else
	echo "Error: settings.json file does not contain expected configuration."
	exit 1
fi

# 測試完成
echo "All tests passed successfully!"

# 清理測試資料夾（可選）
# rm -rf "$TEST_DIR"
