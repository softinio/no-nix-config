if vim.g.vscode then
  -- VSCode Neovim
  require("user.vscode_keymaps")
else
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  require("lazy").setup("plugins", {
    lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", -- in data directory as normal location read only as managed by nix
    dev = {
      path = "~/Projects/Neovim",
    },
  })

  -- [[ Setting options ]]
  -- See `:help vim.o`

  -- Terminal colors
  vim.o.termguicolors = true

  -- conceal level (needed for obsidian)
  vim.o.conceallevel = 1

  -- Set highlight on search
  vim.o.hlsearch = true
  vim.o.incsearch = true

  -- clipboard
  vim.o.clipboard = "unnamedplus"

  -- Make line numbers default
  vim.wo.number = true
  vim.wo.relativenumber = true

  -- Cursor line
  vim.o.cursorline = true

  -- Enable mouse mode
  vim.o.mouse = "a"

  -- Enable break indent
  vim.o.breakindent = true

  -- smart indenting
  vim.o.smartindent = true

  -- Tab settings
  vim.o.expandtab = true
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2

  -- Save undo history
  vim.o.undofile = true

  -- Disable swap and backup files
  vim.o.swapfile = false
  vim.o.backup = false

  -- Case insensitive searching UNLESS /C or capital in search
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Decrease update time
  vim.o.updatetime = 100
  vim.wo.signcolumn = "auto"

  -- Scrolling
  vim.o.scrolloff = 8

  -- Line wrapping
  vim.o.wrap = false

  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- Set completeopt to have a better completion experience
  vim.o.completeopt = "menuone,noselect"

  -- [[ Basic Keymaps ]]

  -- Keymaps for better default experience
  -- See `:help vim.keymap.set()`
  vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

  -- Clear search highlighting
  vim.keymap.set("n", "<esc>", ":noh<CR>", { silent = true })

  -- Yank to end of line
  vim.keymap.set("n", "Y", "y$")

  -- Switch to alternate buffer
  vim.keymap.set("n", "<C-c>", ":b#<CR>")

  -- Close window
  vim.keymap.set("n", "<C-x>", ":close<CR>")

  -- Save file
  vim.keymap.set("n", "<leader>w", ":w<CR>")
  vim.keymap.set("n", "<C-s>", ":w<CR>")

  -- Window navigation
  vim.keymap.set("n", "<leader>h", "<C-w>h")
  vim.keymap.set("n", "<leader>l", "<C-w>l")

  -- Start/End of line
  vim.keymap.set("n", "L", "$")
  vim.keymap.set("n", "H", "^")

  -- Window resizing
  vim.keymap.set("n", "<C-Up>", ":resize -2<CR>")
  vim.keymap.set("n", "<C-Down>", ":resize +2<CR>")
  vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>")
  vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>")

  -- Move lines
  vim.keymap.set("n", "<M-k>", ":move-2<CR>")
  vim.keymap.set("n", "<M-j>", ":move+<CR>")

  -- Visual mode indentation
  vim.keymap.set("v", ">", ">")
  vim.keymap.set("v", "<", "<")
  vim.keymap.set("v", "<TAB>", ">gv")
  vim.keymap.set("v", "<S-TAB>", "<gv")
  vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
  vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

  -- Metals (Scala) keybindings
  vim.keymap.set("n", "<leader>mc", "<cmd>lua require('telescope').extensions.metals.commands()<CR>")
  vim.keymap.set("n", "<leader>mw", "<cmd>lua require('metals').hover_worksheet()<CR>")
  vim.keymap.set("n", "<leader>mt", "<cmd>lua require('metals.tvp').toggle_tree_view()<CR>")
  vim.keymap.set("n", "<leader>mr", "<cmd>lua require('metals.tvp').reveal_in_tree()<CR>")
  vim.keymap.set("n", "<leader>mi", "<cmd>lua require('metals').organize_imports()<CR>")
  vim.keymap.set("n", "<leader>mb", "<cmd>lua require('metals').build_import()<CR>")
  vim.keymap.set("n", "<leader>ms", "<cmd>lua require('metals').super_method_hierarchy()<CR>")
  vim.keymap.set("n", "<leader>mn", "<cmd>lua require('metals').new_scala_file()<CR>")
  vim.keymap.set("n", "<leader>mR", function()
    local clients = vim.lsp.get_clients({ name = "metals" })
    if #clients > 0 then
      clients[1].request("workspace/executeCommand", { command = "metals.build-restart" })
    end
  end)
  vim.keymap.set("n", "<leader>mC", "<cmd>lua require('metals').build_connect()<CR>")
  vim.keymap.set("n", "<leader>md", "<cmd>lua require('metals').open_all_diagnostics()<CR>")

  -- Remap for dealing with word wrap
  vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  -- [[ Highlight on yank ]]
  -- See `:help vim.highlight.on_yank()`
  local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
  })

  -- sets the tab size for json files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "json", "lua", "nix" },
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
    end,
  })

  -- Vertically center document when entering insert mode
  vim.api.nvim_create_autocmd("InsertEnter", {
    command = "norm zz",
  })

  -- Open help in a vertical split
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    command = "wincmd L",
  })

  -- Enable spellcheck for markdown
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    command = "setlocal spell spelllang=en",
  })

  -- Set indentation for swift files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "swift",
    callback = function()
      vim.bo.shiftwidth = 2
      vim.bo.tabstop = 2
      vim.bo.softtabstop = 2
      vim.bo.expandtab = true
    end,
  })

  -- Metals (Scala) - Refresh codelens
  vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    pattern = { "*.scala", "*.sbt", "*.java", "*.sc" },
    command = "lua vim.lsp.codelens.refresh()",
  })

  -- Scala/sbt file type detection
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.sbt", "*.sc" },
    command = "set filetype=scala",
  })

  -- Terminal Escape Key Mapping
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

  -- Diagnostic keymaps
  vim.keymap.set("n", "<leader>k", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end)
  vim.keymap.set("n", "<leader>j", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

  -- The line beneath this is called `modeline`. See `:help modeline`
  -- vim: ts=2 sts=2 sw=2 et
end
