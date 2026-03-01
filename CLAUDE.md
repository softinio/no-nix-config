# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim configuration repository that has been **converted from a nixvim (Nix-based) configuration to a standalone Lua configuration** using lazy.nvim as the package manager. The repository serves two purposes:

1. **Neovim Configuration** - A complete Neovim setup with LSP, formatters, and plugins
2. **Dotfiles Collection** - Standalone configuration files (Fish shell, Git, Jujutsu, WezTerm) for non-Nix systems

### Origin and Synchronization

- The Neovim configuration is kept in sync with the nixvim config at `/Users/salar/.config/nixpkgs/programs/nixvim`
- When syncing from nixvim: plugins, LSP servers, formatters, keymaps, and autocommands should match
- Dotfiles in `dotfiles/` are converted from their Nix equivalents and should work on any system

## Architecture

### Neovim Configuration Structure

```
init.lua                    # Main entry point, sets up lazy.nvim and base config
├── Leader key: <Space>
├── Plugin management: lazy.nvim (lockfile in data directory)
├── VSCode mode detection (uses different keymaps)
└── Global settings, keymaps, and autocommands

lua/plugins/               # Plugin configurations (lazy.nvim auto-loads)
├── init.lua              # Core plugins (tokyonight, trouble, which-key, etc.)
├── lsp.lua               # LSP configuration with multiple servers
├── nvim-cmp.lua          # Completion engine with sources
├── nvim-metals.lua       # Scala/Metals LSP (special handling)
├── telescope.lua         # Fuzzy finder with extensions
├── treesitter.lua        # Syntax highlighting
├── conform.lua           # Code formatting
├── dap.lua               # Debug Adapter Protocol
├── copilot.lua           # GitHub Copilot (copilot-lua)
├── avante.lua            # AI assistant
├── neo-tree.lua          # File explorer
├── lualine.lua           # Status line
└── [other plugins]

lua/user/
└── vscode_keymaps.lua    # VSCode-specific keymaps
```

### Plugin System

- **Package Manager**: lazy.nvim (not Packer, not vim-plug)
- **Plugin Files**: Each file in `lua/plugins/` is auto-loaded by lazy.nvim
- **Plugin Format**: Each file returns a table (or array of tables) with plugin specs
- **Lockfile**: Located at `vim.fn.stdpath("data")/lazy-lock.json` (NOT in repo)

### Key Technology Choices

- **Colorscheme**: tokyonight-night with custom black background (#000000)
- **LSP**: Uses nvim-lspconfig with language-specific servers (NOT coc.nvim, NOT ALE)
- **Completion**: nvim-cmp with copilot-lua (NOT copilot.vim)
- **Formatting**: conform.nvim (NOT null-ls, NOT formatter.nvim)
- **File Explorer**: neo-tree (position: right, width: 30)
- **Fuzzy Finding**: telescope.nvim with extensions
- **Git Signs**: vim-signify (NOT gitsigns)
- **Scala**: nvim-metals with DAP support

## Working with Neovim Configuration

### Testing Changes

```bash
# Start Neovim and run health checks
nvim +checkhealth

# Sync plugins after modifying plugin configs
nvim +Lazy sync

# Check LSP server status
nvim +LspInfo

# View installed plugins
nvim +Lazy
```

### Adding a New Plugin

1. Create a new file in `lua/plugins/` or add to existing file
2. Return lazy.nvim plugin spec table:
   ```lua
   return {
     "author/plugin-name",
     config = function()
       require("plugin-name").setup({})
     end,
   }
   ```
3. Run `:Lazy sync` in Neovim

### Adding an LSP Server

1. Edit `lua/plugins/lsp.lua`
2. Add to the `servers` table with configuration
3. Ensure the LSP server binary is installed (see DEPENDENCIES.md)
4. Restart Neovim and run `:LspInfo` to verify

### Adding a Formatter

1. Edit `lua/plugins/conform.lua`
2. Add to `formatters_by_ft` table
3. Ensure formatter binary is installed
4. Note: Scala uses `format_after_save` (not `format_on_save`) due to slow startup

### Syncing with nixvim

When updating to match the nixvim configuration at `/Users/salar/.config/nixpkgs/programs/nixvim`:

1. Read the nixvim plugin files to understand settings
2. Convert Nix expressions to Lua equivalents:
   - `enable = true` → plugin is included in plugin list
   - `settings = {}` → passed to `.setup()` function
   - `__raw` values → use raw Lua strings/functions
3. Update LSP servers, formatters, keymaps, and autocommands
4. Test thoroughly with `:checkhealth`

## Working with Dotfiles

### Installation Scripts

**`dotfiles/install.sh`** - Intelligently merges dotfiles without duplicates:
- Fish: Checks for existing functions/aliases before adding
- Git: Uses `git config` commands (built-in merge)
- Gitignore: Appends only new patterns
- jj/WezTerm: Asks before replacing
- Always creates `.backup.TIMESTAMP` files

**`install-dependencies.sh`** - Installs required packages:
- Uses MacPorts (NOT Homebrew)
- Offers profiles: Minimal, Full, Full+Scala, Custom
- Installs via: MacPorts, npm, uv (for Python), cargo, coursier
- Automatically installs uv and Python 3.13 if not available

### Dotfiles Structure

```
dotfiles/
├── config.fish          # Fish shell config (NO Nix-related aliases)
├── gitconfig           # Git config (uses nvim as merge tool)
├── gitignore_global    # Global gitignore patterns
├── jj-config.toml      # Jujutsu VCS config
├── wezterm.lua         # WezTerm terminal config
├── install.sh          # Smart merge installation
└── README.md           # Usage instructions
```

### Modifying Dotfiles

**Fish Config (`config.fish`)**:
- NO Nix-related content (no nixc, nixre, nixgc aliases, no nix paths)
- Functions: gitignore
- Aliases use: bat, broot, dua, fzf, lazygit, gh
- API keys loaded from `~/.openai` and `~/.anthropic`

**Git Config (`gitconfig`)**:
- User: Salar Rahmanian <code@softinio.com>
- Merge tool: nvim (NOT IntelliJ IDEA)
- Diff tool: difftastic
- All settings in INI format

**Jujutsu Config (`jj-config.toml`)**:
- Merge editor: nvim (NOT IntelliJ IDEA)
- Diff formatter: difft
- Branch prefix: "softinio-push-"

## Important Keybindings

### Leader Key Mappings (Space as leader)
- `<leader>w` / `<C-s>` - Save file
- `<leader>m` - Toggle NeoTree
- `<leader>ff` - Telescope find files
- `<leader>fg` - Telescope live grep
- `<leader>fb` - Telescope file browser
- `<leader>b` - Telescope buffers
- `<leader>td` - TodoTelescope
- `<leader>,` - Toggle floaterm

### LSP Mappings
- `gd` - Go to definition
- `gD` - Go to references (telescope)
- `gt` - Go to type definition
- `gi` - Go to implementation
- `K` - Hover documentation
- `<F2>` - Rename
- `<leader>k` / `<leader>j` - Previous/next diagnostic

### Scala/Metals Mappings (all under `<leader>m`)
- `<leader>mc` - Metals commands (telescope)
- `<leader>mw` - Hover worksheet
- `<leader>mt` - Toggle tree view
- `<leader>mi` - Organize imports
- `<leader>mR` - Build restart

### DAP Debugging (all under `<leader>d`)
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue
- `<leader>ds` - Step over
- `<leader>di` - Step into
- `<leader>do` - Step out
- `<leader>dt` - Terminate
- `<leader>du` - Toggle DAP UI

## Dependencies

See `DEPENDENCIES.md` for the complete list. Critical dependencies:

**Must Have**:
- `ripgrep`, `fd` - Telescope search
- `nodejs` - Copilot and LSP servers
- `tree-sitter` - Syntax highlighting
- `uv` - Python package manager (installs LSP servers, formatters)
- LSP servers for your languages (installed via npm/uv/cargo)
- Formatters: prettier, stylua, nixfmt, scalafmt

**Scala Development**:
- `metals`, `bloop`, `sbt`, `coursier`, `scalafmt`

## Common Pitfalls

1. **Don't use Homebrew** - This config uses MacPorts. The install scripts expect MacPorts.

2. **Lockfile Location** - The lazy-lock.json is in the data directory, NOT the repo. This is intentional for Nix compatibility.

3. **Copilot Version** - Uses `copilot-lua`, not `copilot.vim`. Different API and keybindings.

4. **Git Signs** - Uses `vim-signify`, not `gitsigns.nvim`. Different highlight groups.

5. **Scala Formatting** - Uses `format_after_save` instead of `format_on_save` due to JVM startup time.

6. **Tree-sitter Indent** - Disabled (`indent.enable = false`). Uses Vim's built-in indentation.

7. **Nix References** - When working with dotfiles, remove ALL Nix-related content. The dotfiles are for non-Nix systems.

8. **Merge Tools** - Both Git and Jujutsu use `nvim` as merge tool, NOT IntelliJ IDEA (that's only in the nixvim version).

## File Naming Conventions

- Plugin files: lowercase with hyphens (e.g., `nvim-cmp.lua`, `neo-tree.lua`)
- No `.disabled` files in the repo (they've been removed)
- Installation scripts: `install.sh` (dotfiles) and `install-dependencies.sh` (packages)

## Testing Installation Scripts

**Dotfiles Install**:
```bash
cd dotfiles
./install.sh
# Check that it merges without duplicates
# Check backups are created
```

**Dependencies Install**:
```bash
./install-dependencies.sh
# Select profile (1=Minimal, 2=Full, 3=Full+Scala, 4=Custom)
# Verify packages install via MacPorts
```
