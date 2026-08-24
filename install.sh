#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/jitterdev/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"
FISHER_PLUGINS="$HOME/.config/fish/fish_plugins"

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
    profile-sync-daemon
    zen-browser-bin
    kwin-effects-better-blur-dx
    kwin-effect-rounded-corners
)

install_aur_helper() {
    command -v paru &>/dev/null || command -v yay &>/dev/null && return

    echo "No AUR helper found. Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git

    local tmpdir
    tmpdir=$(mktemp -d)
    trap "rm -rf '$tmpdir'" RETURN

    git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
    (cd "$tmpdir/paru-bin" && makepkg -si --noconfirm)

    echo "paru installed successfully."
}

install_packages() {
    command -v pacman &>/dev/null || { echo "Error: pacman not found."; exit 1; }
    [[ ${#PACKAGES[@]} -eq 0 ]] && return

    local official=() aur=()

    echo "Syncing package database..."
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
        local helper
        helper=$(command -v paru || command -v yay)
        echo "Installing AUR packages: ${aur[*]}"
        "$helper" -S --needed --noconfirm "${aur[@]}"
    fi
}

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

dot() {
    sudo git --git-dir="$DOTFILES_DIR" --work-tree=/ "$@"
}

fix_ownership() {
    local owner
    owner="$(id -un):$(id -gn)"

    while IFS= read -r file; do
        [[ -n "$file" && -e "/$file" ]] && sudo chown "$owner" "/$file"
    done < <(dot ls-tree -r HEAD --name-only)

    sudo chown -R "$owner" "$DOTFILES_DIR"
    [[ -d "$BACKUP_DIR" ]] && sudo chown -R "$owner" "$BACKUP_DIR"
}

setup_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        echo "Error: $DOTFILES_DIR already exists"
        exit 1
    fi

    echo "Cloning dotfiles..."
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"

    set +e
    checkout_output=$(dot checkout 2>&1)
    checkout_status=$?
    set -e

    if [[ $checkout_status -ne 0 ]]; then
        echo "Backing up conflicting files..."
        echo "$checkout_output" | grep -E "^\s+" | awk '{print $1}' | while read -r file; do
            [[ -z "$file" ]] && continue
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            sudo mv "/$file" "$BACKUP_DIR/$file"
        done
        dot checkout
    fi

    dot config status.showUntrackedFiles no
    dot config clean.requireForce true

    fix_ownership
}

# Main
install_packages
setup_dotfiles
install_fisher_plugins

echo "Done!"