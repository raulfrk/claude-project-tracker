#!/bin/bash
# Post-edit hook: suggests running /review after editing C++ source files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  *.cpp|*.cc|*.cxx|*.h|*.hpp|*.hxx|*.c)
    echo "Tip: Run /review cpp $FILE_PATH to review this file."
    ;;
esac

exit 0
