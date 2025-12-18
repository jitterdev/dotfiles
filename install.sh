#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-git@github.com:jitterdev/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"

git clone --bare "$REPO_URL" "$DOTFILES_DIR"

dot() {
    git --git-dir="$HOME/.dotfiles" --work-tree=/ "$@"
}

# Backup conflicting files
dot checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -r file; do
    mkdir -p "$HOME/.dotfiles-backup/$(dirname "$file")"
    mv "/$file" "$HOME/.dotfiles-backup/$file"
done

dot checkout
dot config status.showUntrackedFiles no

echo "Done!"