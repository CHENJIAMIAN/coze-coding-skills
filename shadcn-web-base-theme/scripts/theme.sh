# !/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The project root is one level up from the scripts directory
SKILL_ROOT="$SCRIPT_DIR/.."

# Run the node command using the absolute path to the dist file
if [ -n "$COZE_WORKSPACE_PATH" ]; then
  echo "WORKSPACE_PATH: $COZE_WORKSPACE_PATH"
  # set the working directory to the COZE_WORKSPACE_PATH
  cd "$COZE_WORKSPACE_PATH"
  SHADCN_THEME_ASSET_DIR="$SKILL_ROOT/assets" node "$SKILL_ROOT/dist/index.js" "$@"
else
  SHADCN_THEME_ASSET_DIR="$SKILL_ROOT/assets" node "$SKILL_ROOT/dist/index.js" "$@"
fi