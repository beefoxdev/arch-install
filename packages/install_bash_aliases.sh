#!/bin/bash

BASHRC="$HOME/.bashrc"

ALIASES=(
  "alias ocserver='opencode attach http://127.0.0.1:4096 --dir ./'"
)

for alias_line in "${ALIASES[@]}"; do
  if grep -Fxq "$alias_line" "$BASHRC"; then
    echo "Alias already exists: $alias_line"
  else
    echo "$alias_line" >> "$BASHRC"
    echo "Added alias: $alias_line"
  fi
done
