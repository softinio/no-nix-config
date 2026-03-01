# Required Dependencies for Neovim Configuration

This document lists packages from your Nix configuration that you should install on non-Nix systems to support your Neovim setup and dotfiles.

## Critical - LSP Servers (for Neovim)

These are **required** for LSP functionality in your Neovim configuration:

### Python
- `basedpyright` - Python LSP server
- `pyrefly` - Python type checker

### Shell
- `bash-language-server`

### Lua
- `lua-language-server`

### Web Development
- `typescript-language-server`
- `vscode-langservers-extracted` - Provides: html, css, json, eslint LSPs

### Configuration Files
- `yaml-language-server`
- `jq-lsp` - JSON query LSP

### Nix (only if you use Nix)
- `nil` - Nix LSP
- `nixd` - Nix LSP (alternative/complement to nil)

### Scala (if you do Scala development)
- `metals` - Scala LSP
- `coursier` - Scala dependency manager (required for metals)
- `bloop` - Scala build server

### Zig
- `zls` - Zig language server

## Critical - Formatters (for conform.nvim)

These are **required** for code formatting in Neovim:

- `prettier` - JSON, JS, TS, etc.
- `stylua` - Lua formatter
- `nixfmt` - Nix formatter
- `scalafmt` - Scala formatter

## Critical - Core Tools

These tools are **essential** for your configurations to work:

### Version Control
- `difftastic` - Used by git and jujutsu for diffs
- `git-lfs` - Git Large File Storage (referenced in gitconfig)
- `gh` - GitHub CLI (used in fish aliases)
- `jj` (jujutsu) - Version control (completions in fish config)

### Development
- `nodejs` - Required for copilot-lua and some LSP servers
- `tree-sitter` - Required for nvim-treesitter

### Search & Navigation
- `ripgrep` - Required for telescope.nvim grep functionality
- `fd` - Required for telescope.nvim file finding
- `fzf` - Fuzzy finder (used in fish config)

### File & Text Tools
- `bat` - Better cat (aliased in fish, used in fzf preview)
- `direnv` - Environment variable manager (used in fish config)

### UI/Terminal
- `lazygit` - Terminal UI for git (aliased as 'lg')

## Recommended - Enhanced CLI Tools

These tools are referenced in your fish config aliases:

- `broot` - Better tree (aliased as 'bf')
- `dua` - Disk usage analyzer (aliased as 'du')
- `prettyping` - Better ping (aliased as 'ping')
- `eza` - Better ls (configured in home.nix)
- `starship` - Better prompt (configured for fish)
- `tealdeer` - tldr pages (faster man pages)

## Optional - Development Tools

Useful but not strictly required:

### Scala Development Stack (if doing Scala)
- `sbt` - Scala build tool
- `scala-cli` - Scala scripting

### Build Tools
- `cmake` - C/C++ build system
- `maven` - Java build tool

### Languages
- `deno` - JavaScript/TypeScript runtime
- `go` - Go language
- `python3` - Python (with pip/uv for package management)
- `rustup` - Rust toolchain manager
- `zig` - Zig language
- `typescript` - TypeScript compiler

### Documentation & Publishing
- `pandoc` - Universal document converter
- `mermaid-cli` - Diagram generation
- `typst` - Modern typesetting system

### Utilities
- `imagemagick` - Image manipulation
- `ffmpeg` - Video/audio processing
- `jq` - JSON processor
- `yq` - YAML processor
- `tree` - Directory tree viewer
- `tokei` - Code statistics

## Automated Installation

For automated installation, use the included script:

```bash
./install-dependencies.sh
```

The script offers different installation profiles:
- **Minimal** - Essential LSP servers and core tools only (MacPorts + npm + pip)
- **Full** - Everything except Scala tools (adds cargo packages)
- **Full + Scala** - Complete setup including Scala development
- **Custom** - Choose what to install interactively

The script uses:
- **MacPorts** for core system tools (ripgrep, fd, fzf, bat, nodejs, etc.)
- **npm** for LSP servers (after installing nodejs via MacPorts)
- **pip/pipx** for Python tools
- **cargo** for Rust-based tools (optional, offers to install rustup)
- **coursier** for Scala tools (only if selected)

## Installation Priority

### 1. Must Install First (Neovim won't work properly without these):
- All LSP servers for languages you use
- All formatters (prettier, stylua, etc.)
- ripgrep, fd, nodejs, tree-sitter
- bat, difftastic

### 2. Should Install Soon (Referenced in configs):
- fzf, direnv, lazygit, gh, jj
- broot, dua, prettyping (for fish aliases)

### 3. Nice to Have:
- starship, eza, tealdeer
- Language-specific tools (if you use those languages)

## Installation with MacPorts

### Essential LSP & Formatters
```bash
# Install MacPorts first from: https://www.macports.org/install.php

# Core search and navigation tools
sudo port install ripgrep fd fzf bat tree-sitter

# Node.js (required for many LSP servers and copilot)
sudo port install nodejs22

# LSP servers via npm (after installing nodejs)
sudo npm install -g bash-language-server
sudo npm install -g typescript-language-server
sudo npm install -g vscode-langservers-extracted
sudo npm install -g yaml-language-server
sudo npm install -g pyright

# Formatters
sudo npm install -g prettier
sudo port install lua-language-server  # includes stylua in some packages

# Git tools
sudo port install git-lfs difftastic lazygit gh

# Fish shell and tools
sudo port install fish direnv starship eza
```

### Python LSP & Tools
```bash
# Install uv (modern Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python 3.13 if not available globally
uv python install 3.13

# Install Python tools via uv (isolated, fast)
uv tool install basedpyright
uv tool install ruff
uv tool install black
uv tool install isort
uv tool install flake8
```

### Rust-based Tools (via cargo)
```bash
# Install Rust first
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Then install tools
cargo install stylua ripgrep fd-find bat tree-sitter-cli
cargo install broot dua-cli
```

### Scala Tools (if doing Scala development)
```bash
# Coursier (Scala tooling installer)
curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-apple-darwin.gz | gzip -d > cs
chmod +x cs
./cs setup

# Then install Scala tools via coursier
cs install metals
cs install bloop
cs install sbt
cs install scala-cli
cs install scalafmt
```

### Zig
```bash
sudo port install zig
# zls (Zig LSP) usually comes with zig or install separately
```

### Jujutsu (jj)
```bash
# Install from cargo
cargo install jj-cli

# Or download binary from: https://github.com/martinvonz/jj/releases
```

### Additional Nice-to-Have Tools
```bash
sudo port install tealdeer pandoc imagemagick ffmpeg jq yq tree tokei
```

## Alternative Installation Methods

### Homebrew (if preferred over MacPorts)
```bash
brew install ripgrep fd fzf bat difftastic tree-sitter
brew install nodejs gh lazygit jj direnv
brew install fish starship eza tealdeer
brew install lua-language-server stylua prettier
```

### Language-specific package managers
```bash
# npm (for LSP servers)
npm install -g bash-language-server typescript-language-server
npm install -g vscode-langservers-extracted yaml-language-server
npm install -g prettier

# Python (uv - preferred)
uv tool install basedpyright
uv tool install ruff
uv tool install black
uv tool install isort

# Rust (cargo)
cargo install ripgrep fd-find bat stylua tree-sitter-cli broot dua-cli

# Scala (coursier)
cs install metals bloop sbt scala-cli scalafmt
```

## Quick Start Script

Here's a quick start script to install the most essential tools:

```bash
#!/bin/bash
# Install essential tools for Neovim config

# Install nodejs and npm packages
sudo port install nodejs22
sudo npm install -g bash-language-server typescript-language-server \
  vscode-langservers-extracted yaml-language-server prettier

# Install core tools
sudo port install ripgrep fd fzf bat difftastic git-lfs gh lazygit \
  fish direnv tree-sitter

# Install via cargo (if rust is installed)
if command -v cargo &> /dev/null; then
  cargo install stylua ripgrep fd-find bat broot dua-cli
fi

# Install Python tools
pip install basedpyright ruff black isort
```

## Notes

- This list is based on your nixvim LSP configuration, conform.nvim formatters, and fish shell aliases
- You don't need to install everything - only what you actually use
- Most critical: LSP servers for your languages + ripgrep/fd for telescope
- Scala tools (metals, bloop, sbt, etc.) only needed if you do Scala development
- Many LSP servers are available via npm, so nodejs is essential
- Some tools (like stylua, ripgrep) are best installed via cargo (Rust package manager)
