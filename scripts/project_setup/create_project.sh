#!/bin/bash
#
# Create a CLI-first project with standardized project structures.
#
# Supported project types:
#   cli-tool : General CLI / pipeline tool
#   dl-tool  : Deep learning tool with training, evaluation, inference, and export modules
#
# Usage:
#   create_project.sh <project_directory> [--type cli-tool|dl-tool] [--package package_name] [--cli-name cli_name]
#
# Examples:
#   create_project.sh ~/ampire-discovery --type cli-tool --package ampire --cli-name ampire
#   create_project.sh ~/ampire-protein-lm --type dl-tool --package ampire_protein_lm --cli-name ampire-protein-lm
#
# Recommended shell wrapper:
#
# createproject() {
#     if [ $# -lt 1 ]; then
#         echo "Usage: createproject <project_directory> [--type cli-tool|dl-tool] [--package package_name] [--cli-name cli_name]"
#         return 1
#     fi
#     bash ~/Automation-Scripts/scripts/project_setup/create_project.sh "$@"
# }

set -euo pipefail

# =========================
# Defaults
# =========================
PROJECT_TYPE="cli-tool"
PACKAGE_NAME=""
CLI_NAME=""

# =========================
# Usage
# =========================
print_usage() {
  cat << EOF
Usage:
  $0 <project_directory> [--type cli-tool|dl-tool] [--package package_name] [--cli-name cli_name]

Options:
  --type       Project template type. Supported: cli-tool, dl-tool
  --package    Python package name under src/. Example: ampire, ampire_protein_lm
  --cli-name   CLI command name. Example: ampire, ampire-protein-lm
  -h, --help   Show this help message

Examples:
  $0 ~/ampire-discovery --type cli-tool --package ampire --cli-name ampire
  $0 ~/ampire-protein-lm --type dl-tool --package ampire_protein_lm --cli-name ampire-protein-lm
EOF
}

# =========================
# Input validation
# =========================
if [ $# -lt 1 ]; then
  print_usage
  exit 1
fi

directory="$1"
shift

# =========================
# Parse optional arguments
# =========================
while [ $# -gt 0 ]; do
  case "$1" in
    --type)
      PROJECT_TYPE="${2:-}"
      shift 2
      ;;
    --package)
      PACKAGE_NAME="${2:-}"
      shift 2
      ;;
    --cli-name)
      CLI_NAME="${2:-}"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1"
      print_usage
      exit 1
      ;;
  esac
done

# =========================
# Validate project type
# =========================
case "$PROJECT_TYPE" in
  cli-tool|dl-tool)
    ;;
  *)
    echo "Error: Unsupported project type: $PROJECT_TYPE"
    echo "Supported types: cli-tool, dl-tool"
    exit 1
    ;;
esac

# =========================
# Derived names
# =========================
PROJECT_BASENAME="$(basename "$directory")"
PROJECT_DIST_NAME="$(echo "$PROJECT_BASENAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"
ENV_NAME="$(echo "$PROJECT_BASENAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_' | tr ' ' '_')"

# Infer package name if not provided.
if [ -z "$PACKAGE_NAME" ]; then
  PACKAGE_NAME="$(echo "$PROJECT_BASENAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_' | tr ' ' '_')"
fi

# Infer CLI name if not provided.
if [ -z "$CLI_NAME" ]; then
  CLI_NAME="$PROJECT_DIST_NAME"
fi

# =========================
# Validate names
# =========================
if ! [[ "$PACKAGE_NAME" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
  echo "Error: Invalid Python package name: $PACKAGE_NAME"
  echo "Package name must be a valid Python identifier, e.g. ampire or ampire_protein_lm."
  exit 1
fi

if ! [[ "$CLI_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "Error: Invalid CLI name: $CLI_NAME"
  echo "CLI name should contain only letters, numbers, hyphens, or underscores, and must not start with a hyphen."
  exit 1
fi

# =========================
# Create root directory
# =========================
if [ ! -d "$directory" ]; then
  mkdir -p "$directory"
  echo "Created project directory: $directory"
else
  echo "Error: $directory already exists."
  echo "Please choose a new project directory."
  exit 1
fi

# =========================
# Helper functions
# =========================
touch_init() {
  local dir="$1"
  touch "$dir/__init__.py"
}

touch_gitkeep() {
  local dir="$1"
  touch "$dir/.gitkeep"
}

write_gitignore() {
  cat > "$directory/.gitignore" << 'EOF'
# =========================
# Python
# =========================
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
*.egg-info/
.eggs/
build/
dist/
develop-eggs/
downloads/
eggs/
lib/
lib64/
parts/
sdist/
var/
.installed.cfg
*.egg

# =========================
# Virtual environments
# =========================
.env
.venv/
venv/
ENV/
env/
conda-meta/

# =========================
# Testing / linting / typing cache
# =========================
.pytest_cache/
.mypy_cache/
.ruff_cache/
.coverage
htmlcov/

# =========================
# Jupyter
# =========================
.ipynb_checkpoints/

# =========================
# Logs and runtime outputs
# =========================
*.log
logs/*
!logs/.gitkeep
tmp/
temp/
*.tmp
*.temp

# =========================
# Data artifacts
# Keep examples under version control.
# =========================
data/raw/*
!data/raw/.gitkeep
data/interim/*
!data/interim/.gitkeep
data/processed/*
!data/processed/.gitkeep
data/tokenized/*
!data/tokenized/.gitkeep

# External data can be large. Keep folder, ignore contents.
data/external/*
!data/external/.gitkeep

# =========================
# Experiment and result artifacts
# =========================
experiments/*
!experiments/.gitkeep
results/*
!results/.gitkeep
!results/figures/
!results/tables/
!results/reports/
results/figures/*
!results/figures/.gitkeep
results/tables/*
!results/tables/.gitkeep
results/reports/*
!results/reports/.gitkeep

# =========================
# Models and checkpoints
# =========================
models/pretrained/*
!models/pretrained/.gitkeep
models/checkpoints/*
!models/checkpoints/.gitkeep
models/exported/*
!models/exported/.gitkeep

*.pt
*.pth
*.ckpt
*.safetensors
*.bin

# =========================
# OS / editor
# =========================
.DS_Store
*~
*.swp
.vscode/
.idea/

# =========================
# Project-specific temporary files
# =========================
backup.py
tmp.py
EOF
}

write_pyproject() {
  cat > "$directory/pyproject.toml" << EOF
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$PROJECT_DIST_NAME"
version = "0.1.0"
description = "A CLI-first, config-driven project."
readme = "README.md"
requires-python = ">=3.10"
authors = [
  { name = "Your Name", email = "your.email@example.com" }
]
dependencies = [
  "pyyaml>=6.0",
  "pandas>=2.0",
  "tqdm>=4.66"
]

[project.optional-dependencies]
dev = [
  "pytest>=7.0",
  "ruff>=0.4.0",
  "mypy>=1.8"
]

[project.scripts]
$CLI_NAME = "$PACKAGE_NAME.cli:main"

[tool.setuptools.packages.find]
where = ["src"]

[tool.ruff]
line-length = 88

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF
}

write_environment() {
  cat > "$directory/environment.yml" << EOF
name: $ENV_NAME
channels:
  - conda-forge
dependencies:
  - python=3.10
  - pip
  - pip:
      - -e .
EOF
}

write_makefile_common() {
  cat > "$directory/Makefile" << EOF
.RECIPEPREFIX := >
.PHONY: help install test lint format clean

help:
>@echo "Available commands:"
>@echo "  make install   Install package in editable mode"
>@echo "  make test      Run tests"
>@echo "  make lint      Run ruff checks"
>@echo "  make format    Format code with ruff"
>@echo "  make clean     Remove cache files"
EOF
}

append_makefile_cli_tool() {
  cat >> "$directory/Makefile" << EOF
>@echo "  make run-example  Run example CLI stage"

install:
>pip install -e .[dev]

test:
>pytest

lint:
>ruff check src tests

format:
>ruff format src tests

run-example:
>$CLI_NAME run example.stage --config configs/examples/stages/example_stage.example.yaml

clean:
>find . -type d -name "__pycache__" -exec rm -rf {} +
>find . -type d -name ".pytest_cache" -exec rm -rf {} +
>find . -type d -name ".ruff_cache" -exec rm -rf {} +
>find . -type d -name "*.egg-info" -exec rm -rf {} +
EOF
}

append_makefile_dl_tool() {
  cat >> "$directory/Makefile" << EOF
>@echo "  make prepare      Prepare dataset"
>@echo "  make train-smoke  Run smoke training"
>@echo "  make train        Run main training"
>@echo "  make evaluate     Evaluate model"
>@echo "  make infer        Run inference"
>@echo "  make export       Export model"

install:
>pip install -e .[dev]

test:
>pytest

lint:
>ruff check src tests

format:
>ruff format src tests

prepare:
>$CLI_NAME prepare --config configs/data/dataset.yaml

train-smoke:
>$CLI_NAME train --config configs/train/smoke.yaml

train:
>$CLI_NAME train --config configs/train/train_main.yaml

evaluate:
>$CLI_NAME evaluate --config configs/eval/eval.yaml

infer:
>$CLI_NAME infer --config configs/infer/infer.yaml

export:
>$CLI_NAME export --config configs/model/export.yaml

clean:
>find . -type d -name "__pycache__" -exec rm -rf {} +
>find . -type d -name ".pytest_cache" -exec rm -rf {} +
>find . -type d -name ".ruff_cache" -exec rm -rf {} +
>find . -type d -name "*.egg-info" -exec rm -rf {} +
EOF
}

write_readme_cli_tool() {
  cat > "$directory/README.md" << EOF
# $PROJECT_BASENAME

This is the official codebase for **$PROJECT_BASENAME**.

> Project type: **cli-tool**
> Python package: **$PACKAGE_NAME**
> CLI command: **$CLI_NAME**

## Overview

This project follows a CLI-first, config-driven, and reproducible project structure.

It is designed for command-line tools, data processing pipelines, and reproducible workflow execution.

## Installation

Create the environment:

\`\`\`bash
conda env create -f environment.yml
conda activate $ENV_NAME
\`\`\`

Install the package in editable mode:

\`\`\`bash
pip install -e .[dev]
\`\`\`

Or use:

\`\`\`bash
make install
\`\`\`

## Quick Start

Show help:

\`\`\`bash
$CLI_NAME --help
\`\`\`

Run a pipeline stage:

\`\`\`bash
$CLI_NAME run <stage_name> --config configs/stages/<stage_name>.yaml
\`\`\`

Example:

\`\`\`bash
$CLI_NAME run example.stage --config configs/examples/stages/example_stage.example.yaml
\`\`\`

Or use:

\`\`\`bash
make run-example
\`\`\`

## Project Structure

\`\`\`text
configs/      Configuration files and stage examples
data/         Data lifecycle directories
experiments/  Reproducible run outputs
results/      Aggregated outputs, reports, figures, and tables
src/          Source code package
tests/        Unit and integration tests
docs/         Documentation
notebooks/    Exploratory notebooks
\`\`\`

## Development

Run tests:

\`\`\`bash
make test
\`\`\`

Run lint checks:

\`\`\`bash
make lint
\`\`\`

Format code:

\`\`\`bash
make format
\`\`\`

Clean cache files:

\`\`\`bash
make clean
\`\`\`

## Documentation

See the \`docs/\` directory for usage, configuration, pipeline, output, and development notes.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## Acknowledgements

We sincerely thank the authors of the open-source projects used in this work.
EOF
}

write_readme_dl_tool() {
  cat > "$directory/README.md" << EOF
# $PROJECT_BASENAME

This is the official codebase for **$PROJECT_BASENAME**.

> Project type: **dl-tool**
> Python package: **$PACKAGE_NAME**
> CLI command: **$CLI_NAME**

## Overview

This project follows a CLI-first, config-driven, and reproducible deep learning project structure.

It is designed for projects involving data preparation, model training, evaluation, model export, and inference.

## Installation

Create the environment:

\`\`\`bash
conda env create -f environment.yml
conda activate $ENV_NAME
\`\`\`

Install the package in editable mode:

\`\`\`bash
pip install -e .[dev]
\`\`\`

Or use:

\`\`\`bash
make install
\`\`\`

## Quick Start

Show help:

\`\`\`bash
$CLI_NAME --help
\`\`\`

Prepare data:

\`\`\`bash
$CLI_NAME prepare --config configs/data/dataset.yaml
\`\`\`

Run smoke training:

\`\`\`bash
$CLI_NAME train --config configs/train/smoke.yaml
\`\`\`

Run main training:

\`\`\`bash
$CLI_NAME train --config configs/train/train_main.yaml
\`\`\`

Evaluate a model:

\`\`\`bash
$CLI_NAME evaluate --config configs/eval/eval.yaml
\`\`\`

Run inference:

\`\`\`bash
$CLI_NAME infer --config configs/infer/infer.yaml
\`\`\`

Export a model:

\`\`\`bash
$CLI_NAME export --config configs/model/export.yaml
\`\`\`

## Makefile Shortcuts

\`\`\`bash
make prepare
make train-smoke
make train
make evaluate
make infer
make export
\`\`\`

## Project Structure

\`\`\`text
configs/      Data, tokenizer, model, training, evaluation, and inference configs
data/         Data lifecycle directories, including tokenized datasets
models/       Pretrained models, checkpoints, and exported model artifacts
experiments/  Reproducible training and evaluation runs
results/      Evaluation outputs, inference outputs, figures, and reports
src/          Source code package
tests/        Unit and integration tests
docs/         Documentation
notebooks/    Exploratory and debugging notebooks
\`\`\`

## Model Lifecycle

This project separates the deep learning lifecycle into clear stages:

\`\`\`text
data preparation
→ tokenization / dataset construction
→ training
→ evaluation
→ model export
→ inference
\`\`\`

## Development

Run tests:

\`\`\`bash
make test
\`\`\`

Run lint checks:

\`\`\`bash
make lint
\`\`\`

Format code:

\`\`\`bash
make format
\`\`\`

Clean cache files:

\`\`\`bash
make clean
\`\`\`

## Documentation

See the \`docs/\` directory for training, inference, evaluation, model export, configuration, and development notes.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## Acknowledgements

We sincerely thank the authors of the open-source projects used in this work.
EOF
}

write_cli_py() {
  cat > "$directory/src/$PACKAGE_NAME/cli.py" << EOF
"""Command-line interface for $PROJECT_BASENAME."""

from __future__ import annotations

import argparse
from pathlib import Path


PROJECT_TYPE = "$PROJECT_TYPE"


def build_parser() -> argparse.ArgumentParser:
    """Build the top-level CLI parser."""
    parser = argparse.ArgumentParser(
        prog="$CLI_NAME",
        description="CLI-first project entry point.",
    )

    subparsers = parser.add_subparsers(dest="command")

    run_parser = subparsers.add_parser(
        "run",
        help="Run a registered pipeline stage.",
    )
    run_parser.add_argument(
        "stage",
        help="Stage name, e.g. example.stage.",
    )
    run_parser.add_argument(
        "--config",
        required=True,
        type=Path,
        help="Path to a YAML configuration file.",
    )

    if PROJECT_TYPE == "dl-tool":
        for command_name in ["prepare", "train", "evaluate", "infer", "export"]:
            command_parser = subparsers.add_parser(
                command_name,
                help=f"Run the {command_name} workflow.",
            )
            command_parser.add_argument(
                "--config",
                required=True,
                type=Path,
                help="Path to a YAML configuration file.",
            )

    return parser


def main() -> None:
    """Run the CLI."""
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "run":
        print(f"Running stage: {args.stage}")
        print(f"Using config: {args.config}")
        print("TODO: connect this command to the stage registry.")
        return

    if PROJECT_TYPE == "dl-tool" and args.command in {
        "prepare",
        "train",
        "evaluate",
        "infer",
        "export",
    }:
        print(f"Running workflow: {args.command}")
        print(f"Using config: {args.config}")
        print("TODO: connect this command to the corresponding pipeline.")
        return

    parser.print_help()


if __name__ == "__main__":
    main()
EOF
}

write_common_docs() {
  cat > "$directory/docs/usage.md" << EOF
# Usage

This document describes how to use the CLI.

\`\`\`bash
$CLI_NAME --help
\`\`\`
EOF

  cat > "$directory/docs/configuration.md" << EOF
# Configuration

This project is config-driven. Store reusable YAML configuration files under \`configs/\`.
EOF

  cat > "$directory/docs/development.md" << EOF
# Development

Install the package in editable mode:

\`\`\`bash
pip install -e .[dev]
\`\`\`

Run tests:

\`\`\`bash
pytest
\`\`\`
EOF
}

# =========================
# Common structure
# =========================
create_common_structure() {
  # Configs
  mkdir -p "$directory/configs/examples/inputs"
  mkdir -p "$directory/configs/examples/stages"
  mkdir -p "$directory/configs/inputs"
  mkdir -p "$directory/configs/logging"
  mkdir -p "$directory/configs/stages"

  # Data lifecycle
  mkdir -p "$directory/data/examples"
  mkdir -p "$directory/data/raw"
  mkdir -p "$directory/data/external"
  mkdir -p "$directory/data/interim"
  mkdir -p "$directory/data/processed"

  # Outputs
  mkdir -p "$directory/experiments"
  mkdir -p "$directory/results/figures"
  mkdir -p "$directory/results/tables"
  mkdir -p "$directory/results/reports"
  mkdir -p "$directory/logs"

  # Notebooks
  mkdir -p "$directory/notebooks/eda"
  mkdir -p "$directory/notebooks/experiments"
  mkdir -p "$directory/notebooks/figures"
  mkdir -p "$directory/notebooks/reports"

  # Scripts, tests, docs
  mkdir -p "$directory/scripts"
  mkdir -p "$directory/tests/unit"
  mkdir -p "$directory/tests/integration"
  mkdir -p "$directory/docs"

  # Python package
  mkdir -p "$directory/src/$PACKAGE_NAME"
  touch_init "$directory/src/$PACKAGE_NAME"

  # Common package modules
  mkdir -p "$directory/src/$PACKAGE_NAME/pipelines"
  mkdir -p "$directory/src/$PACKAGE_NAME/processing"
  mkdir -p "$directory/src/$PACKAGE_NAME/registry"
  mkdir -p "$directory/src/$PACKAGE_NAME/runtime/logging"
  mkdir -p "$directory/src/$PACKAGE_NAME/schemas"
  mkdir -p "$directory/src/$PACKAGE_NAME/utils"
  mkdir -p "$directory/src/$PACKAGE_NAME/visualization"

  touch_init "$directory/src/$PACKAGE_NAME/pipelines"
  touch_init "$directory/src/$PACKAGE_NAME/processing"
  touch_init "$directory/src/$PACKAGE_NAME/registry"
  touch_init "$directory/src/$PACKAGE_NAME/runtime"
  touch_init "$directory/src/$PACKAGE_NAME/runtime/logging"
  touch_init "$directory/src/$PACKAGE_NAME/schemas"
  touch_init "$directory/src/$PACKAGE_NAME/utils"
  touch_init "$directory/src/$PACKAGE_NAME/visualization"

  touch "$directory/src/$PACKAGE_NAME/exceptions.py"

  # Gitkeep files for ignored directories
  touch_gitkeep "$directory/data/raw"
  touch_gitkeep "$directory/data/external"
  touch_gitkeep "$directory/data/interim"
  touch_gitkeep "$directory/data/processed"
  touch_gitkeep "$directory/experiments"
  touch_gitkeep "$directory/results"
  touch_gitkeep "$directory/results/figures"
  touch_gitkeep "$directory/results/tables"
  touch_gitkeep "$directory/results/reports"
  touch_gitkeep "$directory/logs"
  touch_gitkeep "$directory/tests/unit"
  touch_gitkeep "$directory/tests/integration"
  touch_gitkeep "$directory/data/examples"

  # Essential project files
  write_gitignore
  write_pyproject
  write_environment
  write_makefile_common
  write_cli_py
  write_common_docs

  touch "$directory/configs/logging/general.json"
}

# =========================
# CLI-tool structure
# =========================
create_cli_tool_structure() {
  mkdir -p "$directory/src/$PACKAGE_NAME/inputs"
  touch_init "$directory/src/$PACKAGE_NAME/inputs"

  cat > "$directory/configs/examples/stages/example_stage.example.yaml" << EOF
stage:
  name: example.stage

inputs:
  example_input: data/examples/example.txt

outputs:
  output_dir: experiments/example_stage

runtime:
  log_level: INFO
EOF

  cat > "$directory/configs/stages/example_stage.yaml" << EOF
stage:
  name: example.stage

inputs:
  example_input: data/examples/example.txt

outputs:
  output_dir: experiments/example_stage

runtime:
  log_level: INFO
EOF

  touch "$directory/data/examples/example.txt"

  cat > "$directory/docs/pipelines.md" << EOF
# Pipelines

Pipeline stages are registered and executed through the CLI.

\`\`\`bash
$CLI_NAME run <stage_name> --config configs/stages/<stage_name>.yaml
\`\`\`
EOF

  cat > "$directory/docs/outputs.md" << EOF
# Outputs

Each pipeline run should write reproducible outputs under \`experiments/\` and summarized artifacts under \`results/\`.
EOF

  append_makefile_cli_tool
  write_readme_cli_tool
}

# =========================
# DL-tool structure
# =========================
create_dl_tool_structure() {
  # DL-specific configs
  mkdir -p "$directory/configs/data"
  mkdir -p "$directory/configs/tokenizer"
  mkdir -p "$directory/configs/model"
  mkdir -p "$directory/configs/train"
  mkdir -p "$directory/configs/eval"
  mkdir -p "$directory/configs/infer"
  mkdir -p "$directory/configs/generation"

  # DL-specific data and model artifacts
  mkdir -p "$directory/data/tokenized"
  mkdir -p "$directory/models/pretrained"
  mkdir -p "$directory/models/checkpoints"
  mkdir -p "$directory/models/exported"

  mkdir -p "$directory/results/evaluation"
  mkdir -p "$directory/results/inference"

  touch_gitkeep "$directory/data/tokenized"
  touch_gitkeep "$directory/models/pretrained"
  touch_gitkeep "$directory/models/checkpoints"
  touch_gitkeep "$directory/models/exported"
  touch_gitkeep "$directory/results/evaluation"
  touch_gitkeep "$directory/results/inference"

  # DL package modules
  mkdir -p "$directory/src/$PACKAGE_NAME/data"
  mkdir -p "$directory/src/$PACKAGE_NAME/models"
  mkdir -p "$directory/src/$PACKAGE_NAME/training"
  mkdir -p "$directory/src/$PACKAGE_NAME/inference"
  mkdir -p "$directory/src/$PACKAGE_NAME/evaluation"

  touch_init "$directory/src/$PACKAGE_NAME/data"
  touch_init "$directory/src/$PACKAGE_NAME/models"
  touch_init "$directory/src/$PACKAGE_NAME/training"
  touch_init "$directory/src/$PACKAGE_NAME/inference"
  touch_init "$directory/src/$PACKAGE_NAME/evaluation"

  # Data module placeholders
  touch "$directory/src/$PACKAGE_NAME/data/loading.py"
  touch "$directory/src/$PACKAGE_NAME/data/cleaning.py"
  touch "$directory/src/$PACKAGE_NAME/data/tokenization.py"
  touch "$directory/src/$PACKAGE_NAME/data/dataset.py"
  touch "$directory/src/$PACKAGE_NAME/data/collators.py"

  # Model module placeholders
  touch "$directory/src/$PACKAGE_NAME/models/architectures.py"
  touch "$directory/src/$PACKAGE_NAME/models/factory.py"
  touch "$directory/src/$PACKAGE_NAME/models/heads.py"
  touch "$directory/src/$PACKAGE_NAME/models/adapters.py"

  # Training module placeholders
  touch "$directory/src/$PACKAGE_NAME/training/losses.py"
  touch "$directory/src/$PACKAGE_NAME/training/trainer.py"
  touch "$directory/src/$PACKAGE_NAME/training/callbacks.py"
  touch "$directory/src/$PACKAGE_NAME/training/checkpointing.py"
  touch "$directory/src/$PACKAGE_NAME/training/schedulers.py"
  touch "$directory/src/$PACKAGE_NAME/training/distributed.py"

  # Inference module placeholders
  touch "$directory/src/$PACKAGE_NAME/inference/predictor.py"
  touch "$directory/src/$PACKAGE_NAME/inference/generator.py"
  touch "$directory/src/$PACKAGE_NAME/inference/embedder.py"
  touch "$directory/src/$PACKAGE_NAME/inference/postprocess.py"

  # Evaluation module placeholders
  touch "$directory/src/$PACKAGE_NAME/evaluation/metrics.py"
  touch "$directory/src/$PACKAGE_NAME/evaluation/evaluate.py"
  touch "$directory/src/$PACKAGE_NAME/evaluation/reports.py"
  touch "$directory/src/$PACKAGE_NAME/evaluation/plots.py"

  # Pipeline placeholders
  touch "$directory/src/$PACKAGE_NAME/pipelines/prepare_data.py"
  touch "$directory/src/$PACKAGE_NAME/pipelines/train_model.py"
  touch "$directory/src/$PACKAGE_NAME/pipelines/evaluate_model.py"
  touch "$directory/src/$PACKAGE_NAME/pipelines/run_inference.py"
  touch "$directory/src/$PACKAGE_NAME/pipelines/export_model.py"

  # Script entry placeholders
  touch "$directory/scripts/prepare_data.py"
  touch "$directory/scripts/train.py"
  touch "$directory/scripts/evaluate.py"
  touch "$directory/scripts/infer.py"
  touch "$directory/scripts/export_model.py"

  # Config placeholders
  cat > "$directory/configs/data/dataset.yaml" << EOF
data:
  name: example_dataset
  raw_dir: data/raw
  processed_dir: data/processed
  tokenized_dir: data/tokenized
EOF

  cat > "$directory/configs/model/model.yaml" << EOF
model:
  name: example_model
  architecture: null
  checkpoint_path: null
EOF

  cat > "$directory/configs/model/export.yaml" << EOF
export:
  checkpoint_path: models/checkpoints/best
  output_dir: models/exported/model-v1
EOF

  cat > "$directory/configs/train/smoke.yaml" << EOF
experiment:
  name: smoke_test
  output_dir: experiments/smoke_test

training:
  max_steps: 10
  batch_size: 2
  learning_rate: 1.0e-4
EOF

  cat > "$directory/configs/train/train_main.yaml" << EOF
experiment:
  name: train_main
  output_dir: experiments/train_main

training:
  num_epochs: 1
  batch_size: 8
  learning_rate: 1.0e-4
EOF

  cat > "$directory/configs/eval/eval.yaml" << EOF
evaluation:
  model_path: models/exported/model-v1
  output_dir: results/evaluation
EOF

  cat > "$directory/configs/infer/infer.yaml" << EOF
inference:
  model_path: models/exported/model-v1
  input_path: data/examples/input.txt
  output_path: results/inference/predictions.csv
EOF

  cat > "$directory/configs/generation/generation.yaml" << EOF
generation:
  model_path: models/exported/model-v1
  output_path: results/inference/generated.txt
EOF

  # Docs
  cat > "$directory/docs/training.md" << EOF
# Training

Run smoke training:

\`\`\`bash
$CLI_NAME train --config configs/train/smoke.yaml
\`\`\`

Run main training:

\`\`\`bash
$CLI_NAME train --config configs/train/train_main.yaml
\`\`\`
EOF

  cat > "$directory/docs/inference.md" << EOF
# Inference

Run inference:

\`\`\`bash
$CLI_NAME infer --config configs/infer/infer.yaml
\`\`\`
EOF

  cat > "$directory/docs/evaluation.md" << EOF
# Evaluation

Run evaluation:

\`\`\`bash
$CLI_NAME evaluate --config configs/eval/eval.yaml
\`\`\`
EOF

  cat > "$directory/docs/model_export.md" << EOF
# Model Export

Export a trained model:

\`\`\`bash
$CLI_NAME export --config configs/model/export.yaml
\`\`\`
EOF

  append_makefile_dl_tool
  write_readme_dl_tool
}

# =========================
# Create project
# =========================
create_common_structure

case "$PROJECT_TYPE" in
  cli-tool)
    create_cli_tool_structure
    ;;
  dl-tool)
    create_dl_tool_structure
    ;;
esac

# =========================
# Completion message
# =========================
echo "Project setup complete."
echo "Directory     : $directory"
echo "Project type  : $PROJECT_TYPE"
echo "Package name  : $PACKAGE_NAME"
echo "CLI name      : $CLI_NAME"
echo "Created at    : $(date +"%Y-%m-%d %H:%M:%S")"

exit 0