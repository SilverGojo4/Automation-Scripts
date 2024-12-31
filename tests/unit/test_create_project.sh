#!/bin/bash
# Test script for create_project.sh

# 定義測試目錄
TEST_DIR=~/test_project

# 執行 create_project.sh 腳本
echo "Running create_project.sh..."
bash ~/Automation-Scripts/scripts/project_setup/create_project.sh "$TEST_DIR"

# 驗證目錄結構
echo "Verifying directory structure..."
EXPECTED_DIRECTORIES=(
	"$TEST_DIR/data/raw"
	"$TEST_DIR/data/processed"
	"$TEST_DIR/data/external"
	"$TEST_DIR/data/interim"
	"$TEST_DIR/notebooks/eda"
	"$TEST_DIR/notebooks/experiments"
	"$TEST_DIR/src/data"
	"$TEST_DIR/src/models"
	"$TEST_DIR/src/evaluation"
	"$TEST_DIR/src/inference"
	"$TEST_DIR/src/utils"
	"$TEST_DIR/logs/data"
	"$TEST_DIR/logs/models"
	"$TEST_DIR/logs/evaluation"
	"$TEST_DIR/logs/inference"
	"$TEST_DIR/experiments/models"
	"$TEST_DIR/experiments/results"
	"$TEST_DIR/experiments/checkpoints"
	"$TEST_DIR/tests/unit"
	"$TEST_DIR/tests/integration"
	"$TEST_DIR/tests/performance"
	"$TEST_DIR/configs"
	"$TEST_DIR/scripts"
)

for dir in "${EXPECTED_DIRECTORIES[@]}"; do
	if [ -d "$dir" ]; then
		echo "Directory exists: $dir"
	else
		echo "Error: Directory missing - $dir"
		exit 1
	fi
done

# 驗證文件
echo "Verifying files..."
EXPECTED_FILES=(
	"$TEST_DIR/.gitignore"
	"$TEST_DIR/requirements.txt"
	"$TEST_DIR/environment.yml"
	"$TEST_DIR/README.md"
)

for file in "${EXPECTED_FILES[@]}"; do
	if [ -f "$file" ]; then
		echo "File exists: $file"
	else
		echo "Error: File missing - $file"
		exit 1
	fi
done

# 測試完成
echo "All tests passed successfully!"

# 清理測試資料夾（可選）
# rm -rf "$TEST_DIR"
