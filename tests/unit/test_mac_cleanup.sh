#!/bin/bash
# Test script for mac_cleanup.sh

# 定義需要測試的路徑
CACHE_DIR=~/Library/Caches
TRASH_DIR=~/.Trash
LOG_DIR=~/Library/Logs
CACHE_HIDDEN_DIR=~/.cache

# 創建測試文件以模擬不同狀況
echo "Creating test files..."
mkdir -p "$CACHE_DIR" "$TRASH_DIR" "$LOG_DIR" "$CACHE_HIDDEN_DIR"
touch "$CACHE_DIR/test_cache_file" "$TRASH_DIR/test_trash_file" "$LOG_DIR/test_log_file" "$CACHE_HIDDEN_DIR/test_hidden_cache_file"

# 檢查測試文件是否存在
echo "Verifying test files were created..."
if [[ -f "$CACHE_DIR/test_cache_file" && -f "$TRASH_DIR/test_trash_file" && -f "$LOG_DIR/test_log_file" && -f "$CACHE_HIDDEN_DIR/test_hidden_cache_file" ]]; then
	echo "Test files created successfully."
else
	echo "Failed to create test files."
	exit 1
fi

# 執行清理腳本
echo "Running cleanup script..."
bash ~/Automation-Scripts/scripts/system/mac_cleanup.sh

# 檢查測試文件是否已被刪除
echo "Checking if test files were deleted..."
if [[ ! -f "$CACHE_DIR/test_cache_file" && ! -f "$TRASH_DIR/test_trash_file" && ! -f "$LOG_DIR/test_log_file" && ! -f "$CACHE_HIDDEN_DIR/test_hidden_cache_file" ]]; then
	echo "Cleanup script executed successfully: All test files were deleted."
else
	echo "Cleanup script failed: Some test files were not deleted."
	exit 1
fi

# 顯示完成訊息
echo "All tests passed successfully!"
