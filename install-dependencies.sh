#!/usr/bin/env bash

# Dependency Installation Script for Neovim Configuration
# Uses MacPorts, cargo, npm, and pip for installation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

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

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check MacPorts installation
check_macports() {
    if ! command_exists port; then
        print_error "MacPorts is not installed!"
        print_info "Install from: https://www.macports.org/install.php"
        exit 1
    fi
    print_success "MacPorts found"
}

# Install via MacPorts
install_macports_packages() {
    print_header "Installing core packages via MacPorts"

    local packages=(
        alacritty
        bat
        difftastic
        direnv
        eza
        fd
        fish
        fzf
        gh
        git-lfs
        jq
        jujutsu
        lazygit
        nodejs22
        npm11
        postgresql18
        postgresql18-server
        redis
        ripgrep
        ripgrep-all
        starship
        tealdeer
        tmux
        tree
        tree-sitter
        uv
        wezterm
    )

    for pkg in "${packages[@]}"; do
        if port installed "$pkg" 2>/dev/null | grep -q "$pkg"; then
            print_success "$pkg already installed"
        else
            print_info "Installing $pkg..."
            sudo port install "$pkg"
        fi
    done
}

# Install Node.js packages
install_npm_packages() {
    if ! command_exists npm; then
        print_error "npm is not available. Install Node.js via MacPorts first."
        print_info "Run: sudo port install nodejs22"
        return 1
    fi

    print_header "Installing npm packages (LSP servers & formatters)"

    local packages=(
        bash-language-server
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
        pyright
        prettier
    )

    for pkg in "${packages[@]}"; do
        if npm list -g "$pkg" &> /dev/null; then
            print_success "$pkg already installed"
        else
            print_info "Installing $pkg..."
            sudo npm install -g "$pkg"
        fi
    done
}

# Install uv tools (globally available CLI tools managed by uv)
install_uv_tools() {
    print_header "Installing uv tools"

    # Check if uv is installed
    if ! command_exists uv; then
        print_warning "uv is not installed. Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"

        if ! command_exists uv; then
            print_error "Failed to install uv"
            return 1
        fi
        print_success "uv installed successfully"
    fi

    # uv tool install manages its own Python internally — no global Python needed
    # uv handles already-installed tools gracefully
    local packages=(ruff ty)

    for pkg in "${packages[@]}"; do
        print_info "Installing $pkg..."
        uv tool install "$pkg"
    done

    # Ensure uv's tool bin directory is on PATH
    uv tool update-shell

    print_success "uv tools installed"
}

# Install Rust and cargo packages
install_cargo_packages() {
    if ! command_exists cargo; then
        print_warning "Rust/cargo is not installed."
        read -p "$(echo -e ${BLUE}Install Rust via rustup? [y/N]:${NC} )" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        else
            print_warning "Skipping cargo packages"
            return 0
        fi
    fi

    print_header "Installing cargo packages"

    local packages=(
        stylua
        dua-cli
        jj-cli
        tmux-sessionizer
    )

    for pkg in "${packages[@]}"; do
        if cargo install --list | grep -q "^$pkg "; then
            print_success "$pkg already installed"
        else
            print_info "Installing $pkg..."
            cargo install "$pkg"
        fi
    done
}

# Install Scala tools via Coursier
install_scala_tools() {
    print_header "Installing Scala development tools"

    if ! command_exists cs; then
        print_info "Installing Coursier..."
        curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-apple-darwin.gz | gzip -d > /tmp/cs
        chmod +x /tmp/cs
        /tmp/cs setup --yes
        rm /tmp/cs
    fi

    local tools=(metals bloop sbt scala-cli scalafmt)
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        cs install "$tool" --yes
    done

    # Install mill globally (not available via Coursier)
    if command_exists mill; then
        print_success "mill already installed"
    else
        print_info "Installing mill globally..."
        local mill_version="1.1.2"
        sudo curl -L \
            "https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/${mill_version}/mill-dist-${mill_version}-mill.sh" \
            -o /usr/local/bin/mill
        sudo chmod +x /usr/local/bin/mill
        print_success "mill installed"
    fi
}

# Install, initialize, and start PostgreSQL and Redis via MacPorts
setup_databases() {
    print_header "Installing & Configuring PostgreSQL & Redis"

    check_macports

    # --- PostgreSQL ---
    for pkg in postgresql18 postgresql18-server; do
        if port installed "$pkg" 2>/dev/null | grep -q "$pkg"; then
            print_success "$pkg already installed"
        else
            print_info "Installing $pkg..."
            sudo port install "$pkg"
        fi
    done

    local pgdata="/opt/local/var/db/postgresql18/defaultdb"
    if [ ! -d "$pgdata" ]; then
        print_info "Initializing PostgreSQL data directory at $pgdata ..."
        sudo mkdir -p "$pgdata"
        sudo chown postgres:postgres "$pgdata"
        sudo -u postgres /opt/local/lib/postgresql18/bin/initdb -D "$pgdata" --encoding=UTF8 --locale=en_US.UTF-8
        print_success "PostgreSQL data directory initialized"
    else
        print_success "PostgreSQL data directory already exists: $pgdata"
    fi

    print_info "Loading PostgreSQL launchd service (starts at login)..."
    sudo port load postgresql18-server
    print_success "PostgreSQL service loaded"

    # --- Redis ---
    if port installed redis 2>/dev/null | grep -q "redis"; then
        print_success "redis already installed"
    else
        print_info "Installing redis..."
        sudo port install redis
    fi

    print_info "Loading Redis launchd service (starts at login)..."
    sudo port load redis
    print_success "Redis service loaded"

    print_info "Connection details:"
    echo "  PostgreSQL: host=localhost port=5432  (psql -U postgres)"
    echo "  Redis:      host=localhost port=6379  (redis-cli)"
}

# Install additional optional tools
install_optional_tools() {
    print_header "Installing optional tools"

    read -p "$(echo -e "${BLUE}Install optional tools (pandoc, imagemagick, ffmpeg, etc.)? [y/N]:${NC} ")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi

    local packages=(pandoc ImageMagick ffmpeg yq tokei)
    for pkg in "${packages[@]}"; do
        if port installed "$pkg" 2>/dev/null | grep -q "$pkg"; then
            print_success "$pkg already installed"
        else
            print_info "Installing $pkg..."
            sudo port install "$pkg"
        fi
    done
}

# Main menu
show_menu() {
    echo ""
    print_header "Neovim Configuration - Dependency Installer"
    echo "Select installation profile:"
    echo ""
    echo "  1) Minimal (Essential LSP + Core tools)"
    echo "  2) Full (Everything except Scala)"
    echo "  3) Full + Scala (Complete setup)"
    echo "  4) Custom (Choose what to install)"
    echo "  5) Configure databases (PostgreSQL + Redis launchd)"
    echo "  6) Exit"
    echo ""
}

# Minimal installation
install_minimal() {
    print_header "Installing Minimal Profile"

    check_macports
    install_macports_packages
    install_npm_packages
    install_uv_tools
}

# Full installation
install_full() {
    print_header "Installing Full Profile"

    install_minimal
    install_cargo_packages
    install_optional_tools

    read -p "$(echo -e "${BLUE}Configure PostgreSQL & Redis services? [y/N]:${NC} ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_databases
    fi
}

# Full + Scala
install_full_scala() {
    print_header "Installing Full Profile + Scala"

    install_full
    install_scala_tools
}

# Custom installation
install_custom() {
    print_header "Custom Installation"

    check_macports

    # MacPorts packages
    read -p "$(echo -e ${BLUE}Install core tools via MacPorts? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_macports_packages
    fi

    # npm packages
    read -p "$(echo -e ${BLUE}Install npm packages (LSP servers)? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_npm_packages
    fi

    # Python packages
    read -p "$(echo -e ${BLUE}Install Python packages? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_uv_tools
    fi

    # Cargo packages
    read -p "$(echo -e ${BLUE}Install cargo packages? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_cargo_packages
    fi

    # Scala tools
    read -p "$(echo -e ${BLUE}Install Scala development tools? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_scala_tools
    fi

    # Optional tools
    install_optional_tools

    # Database services
    read -p "$(echo -e "${BLUE}Configure PostgreSQL & Redis services? [y/N]:${NC} ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_databases
    fi
}

# Main execution
main() {
    while true; do
        show_menu
        read -p "Enter choice [1-6]: " choice

        case $choice in
            1)
                install_minimal
                break
                ;;
            2)
                install_full
                break
                ;;
            3)
                install_full_scala
                break
                ;;
            4)
                install_custom
                break
                ;;
            5)
                setup_databases
                break
                ;;
            6)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-6."
                ;;
        esac
    done

    echo ""
    print_header "Installation Complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.config/fish/config.fish"
    echo "  2. If you installed Rust, run: source \$HOME/.cargo/env"
    echo "  3. Run :Lazy sync in Neovim to install plugins"
    echo "  4. Run :checkhealth in Neovim to verify LSP servers"
    echo ""
    print_info "Installed tools are available at:"
    echo "  - MacPorts: /opt/local/bin/"
    echo "  - npm global: /usr/local/lib/node_modules/"
    echo "  - cargo: ~/.cargo/bin/"
    echo "  - uv tools: ~/.local/bin/ (managed by uv)"
    echo "  - coursier: ~/Library/Application Support/Coursier/bin/"
    echo ""
}

# Run main function
if [[ "${1:-}" == "--databases-only" ]]; then
    setup_databases
else
    main
fi
