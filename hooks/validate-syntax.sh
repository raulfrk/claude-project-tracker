#!/bin/bash
# Post-edit hook: validates YAML and JSON syntax after Claude edits/writes a file

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if [[ "$FILE_PATH" == *.yaml ]] || [[ "$FILE_PATH" == *.yml ]]; then
  if python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" "$FILE_PATH" 2>/dev/null; then
    echo "✅ Valid YAML: $FILE_PATH"
  else
    echo "❌ Invalid YAML: $FILE_PATH"
    python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" "$FILE_PATH" 2>&1
  fi
elif [[ "$FILE_PATH" == *.json ]]; then
  if python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$FILE_PATH" 2>/dev/null; then
    echo "✅ Valid JSON: $FILE_PATH"
  else
    echo "❌ Invalid JSON: $FILE_PATH"
    python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$FILE_PATH" 2>&1
  fi
fi

exit 0
