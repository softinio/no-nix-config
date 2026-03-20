return {
  -- Removed: neoconf, neodev (not in nixvim)
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("tokyonight").setup({
        style = "night",
        on_colors = function(colors)
          colors.bg = "#000000" -- "#1a1b26"
        end,
        on_highlights = function(hl, colors)
          hl.WinSeparator = { fg = "#33ff33", bold = true }
        end,
      })
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup()
    end,
  },
  { "folke/which-key.nvim", lazy = false },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    lazy = false,
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  { "nvim-tree/nvim-web-devicons", config = function() require("nvim-web-devicons").setup() end },
  -- Removed: stylua-nvim, nvim-jqx, scaladex.nvim, mkdx (not in nixvim)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "┊" },
      })
    end,
  },
  -- Git signs
  {
    "mhinz/vim-signify",
    config = function()
      -- vim-signify color customization
      vim.api.nvim_set_hl(0, "SignifySignAdd", { fg = "#00ff00", ctermfg = "green" })
      vim.api.nvim_set_hl(0, "SignifySignDelete", { fg = "#ff0000", ctermfg = "red" })
      vim.api.nvim_set_hl(0, "SignifySignChange", { fg = "#ffff00", ctermfg = "yellow" })
    end,
  },
  -- Flash jump/search
  {
    "folke/flash.nvim",
    config = function()
      require("flash").setup()
    end,
  },
  -- Snacks utility collection
  {
    "folke/snacks.nvim",
    config = function()
      require("snacks").setup({
        bigfile = { enabled = true },
        image = { enabled = true },
        notifier = { enabled = true, timeout = 5000 },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
      })
    end,
  },
  -- Zig support
  "ziglang/zig.vim",
  -- File manager
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    config = function()
      require("oil").setup()
    end,
  },
  -- Typst preview
  "chomosuke/typst-preview.nvim",
  -- Color highlighter
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          names = false,
        },
      })
    end,
  },
  -- UI component library
  "MunifTanjim/nui.nvim",
  -- Markdown preview
  {
    "OXY2DEV/markview.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  -- Floating terminal
  {
    "voldikss/vim-floaterm",
    config = function()
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
      vim.g.floaterm_title = ""
      vim.keymap.set("n", "<leader>,", ":FloatermToggle<CR>")
    end,
  },
}
