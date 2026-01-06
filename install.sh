#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-git@github.com:jitterdev/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"
FISHER_PLUGINS="$HOME/.config/fish/fish_plugins"

# Required packages
PACKAGES=(
    git
    git-delta
    fish
    fisher
    kitty
    fastfetch
    btop
    moor
    bat
    ffmpeg
    ffmpegthumbnailer
    yt-dlp
    fzf
    atool
    poppler
    eza
    vicinae-bin
    spotify-launcher
    spicetify
    plasma-meta
    github-cli
)

# AUR helper installation
install_aur_helper() {
    if command -v paru &>/dev/null || command -v yay &>/dev/null; then
        return
    fi

    echo "No AUR helper found. Installing paru..."

    sudo pacman -S --needed --noconfirm base-devel git

    local tmpdir
    tmpdir=$(mktemp -d)
    trap "rm -rf '$tmpdir'" EXIT

    git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
    cd "$tmpdir/paru-bin"
    makepkg -si --noconfirm
    cd - >/dev/null

    trap - EXIT
    rm -rf "$tmpdir"

    echo "paru installed successfully."
}

# Package installation
install_packages() {
    if ! command -v pacman &>/dev/null; then
        echo "Error: pacman not found. This script requires an Arch-based system."
        exit 1
    fi

    [[ ${#PACKAGES[@]} -eq 0 ]] && return

    local official=()
    local aur=()

    echo "Sorting packages..."
    sudo pacman -Syu --noconfirm

    for pkg in "${PACKAGES[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            official+=("$pkg")
        else
            aur+=("$pkg")
        fi
    done

    if [[ ${#official[@]} -gt 0 ]]; then
        echo "Installing official packages: ${official[*]}"
        sudo pacman -S --needed --noconfirm "${official[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        install_aur_helper

        if command -v paru &>/dev/null; then
            echo "Installing AUR packages with paru: ${aur[*]}"
            paru -S --needed --noconfirm "${aur[@]}"
        elif command -v yay &>/dev/null; then
            echo "Installing AUR packages with yay: ${aur[*]}"
            yay -S --needed --noconfirm "${aur[@]}"
        fi
    fi
}

# Fisher plugins installation
install_fisher_plugins() {
    if [[ ! -f "$FISHER_PLUGINS" ]]; then
        echo "No fish_plugins file found at $FISHER_PLUGINS, skipping Fisher plugins"
        return
    fi

    if ! command -v fish &>/dev/null; then
        echo "Fish shell not found, skipping Fisher plugins installation"
        return
    fi

    echo "Installing Fisher plugins..."
    fish -c "fisher update"
}

# Dotfiles setup
install_packages

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
dot config clean.requireForce true

# Install Fisher plugins after dotfiles are in place
install_fisher_plugins

echo "Done!"