#!/bin/zsh

set -e

SCRIPT_DIR="${0:A:h}"
ZSHRC="$HOME/.zshrc"
DEL_SOURCE="source \"$SCRIPT_DIR/zsh/del.zsh\""

echo "Installing mac-dotfiles..."
echo "Repository: $SCRIPT_DIR"

if [[ ! -f "$SCRIPT_DIR/zsh/del.zsh" ]]; then
    echo "Error: zsh/del.zsh not found."
    exit 1
fi

if [[ ! -f "$ZSHRC" ]]; then
    touch "$ZSHRC"
    echo "Created $ZSHRC"
fi

if ! grep -Fqx "$DEL_SOURCE" "$ZSHRC"; then
    printf '\n%s\n' "$DEL_SOURCE" >> "$ZSHRC"
    echo "Added del.zsh to $ZSHRC"
else
    echo "del.zsh is already configured."
fi

echo "Installation complete."
echo "Run: source ~/.zshrc"
