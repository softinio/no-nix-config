#!/usr/bin/env bash

# Unified Installation Script
# Sets up Neovim config and dotfiles via symbolic links

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# Create a backup of an existing file, directory, or symlink
backup_file() {
    local file="$1"
    # -e covers existing files/dirs/valid symlinks; -L also catches broken symlinks
    if [ -e "$file" ] || [ -L "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backing up: $file → $backup"
        mv "$file" "$backup"
    fi
}

# Create a symbolic link, backing up any existing file first.
# Usage: make_link <link_target> <link_path>
make_link() {
    local target="$1"
    local link="$2"

    mkdir -p "$(dirname "$link")"

    # If the link already points to the correct target, nothing to do
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
        print_success "Already linked: $link → $target"
        return
    fi

    backup_file "$link"
    ln -s "$target" "$link"
    print_success "Linked: $link → $target"
}

# --- Neovim ---
setup_nvim() {
    print_header "Neovim Configuration"
    make_link "$SCRIPT_DIR" "$HOME/.config/nvim"
}

# --- Fish shell ---
setup_fish() {
    print_header "Fish Shell Configuration"
    make_link "$SCRIPT_DIR/dotfiles/config.fish" "$HOME/.config/fish/config.fish"
}

# --- Git ---
setup_git() {
    print_header "Git Configuration"
    make_link "$SCRIPT_DIR/dotfiles/gitconfig" "$HOME/.gitconfig"
    make_link "$SCRIPT_DIR/dotfiles/gitignore_global" "$HOME/.gitignore_global"
}

# --- Jujutsu ---
setup_jj() {
    print_header "Jujutsu Configuration"
    make_link "$SCRIPT_DIR/dotfiles/jj-config.toml" "$HOME/.config/jj/config.toml"
}

# --- WezTerm ---
setup_wezterm() {
    print_header "WezTerm Configuration"
    make_link "$SCRIPT_DIR/dotfiles/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
}

# --- Starship ---
setup_starship() {
    print_header "Starship Configuration"
    make_link "$SCRIPT_DIR/dotfiles/starship.toml" "$HOME/.config/starship.toml"
}

# --- GitHub CLI ---
setup_gh() {
    print_header "GitHub CLI Configuration"
    make_link "$SCRIPT_DIR/dotfiles/gh-config.yml" "$HOME/.config/gh/config.yml"
}

# --- Claude Code ---
setup_claude() {
    print_header "Claude Code Settings"
    make_link "$SCRIPT_DIR/dotfiles/claude-settings.json" "$HOME/.claude/settings.json"
}

# --- Fisher / Fish plugins ---
check_fisher() {
    fish -c "type -q fisher" 2>/dev/null
}

setup_fish_plugins() {
    print_header "Fish Plugins"

    if ! command -v fish &> /dev/null; then
        print_warning "Fish shell not found, skipping plugin setup."
        return
    fi

    if check_fisher; then
        print_success "Fisher is already installed"
    else
        print_warning "Fisher is not installed"
        read -p "$(echo -e "${BLUE}Install Fisher? [y/N]:${NC} ")" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installing Fisher..."
            fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
            if check_fisher; then
                print_success "Fisher installed"
            else
                print_error "Failed to install Fisher"
                return
            fi
        else
            return
        fi
    fi

    read -p "$(echo -e "${BLUE}Install Fish plugins (fish-ssh-agent)? [y/N]:${NC} ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        fish -c "fisher install danhper/fish-ssh-agent"
        print_success "Fish plugins installed"
    fi
}

# --- Main ---
main() {
    print_header "Unified Dotfiles & Neovim Install"
    print_info "All configs will be symlinked from: $SCRIPT_DIR"
    print_info "Existing files will be backed up with a .backup.TIMESTAMP suffix."
    echo ""

    # Install dependencies first
    print_header "Installing Dependencies"
    bash "$SCRIPT_DIR/install-dependencies.sh"

    setup_nvim
    setup_fish
    setup_git
    setup_jj
    setup_wezterm
    setup_starship
    setup_gh
    setup_claude

    read -p "$(echo -e "${BLUE}Set up Fish plugins? [y/N]:${NC} ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_fish_plugins
    fi

    print_header "Done!"
    print_info "Symlinks created. Edits to files in $SCRIPT_DIR take effect immediately."
    print_info "You may need to restart your terminal or run: source ~/.config/fish/config.fish"
    echo ""
}

main
