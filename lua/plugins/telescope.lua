return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
    "debugloop/telescope-undo.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {
          "^.git/",
          "^.mypy_cache/",
          "^__pycache__/",
          "^output/",
          "^data/",
          "%.ipynb",
        },
        set_env = { COLORTERM = "truecolor" },
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
      extensions = {
        ["file_browser"] = {
          auto_depth = true,
          hijack_netrw = true,
          prompt_path = true,
          mappings = {
            ["i"] = {
              ["<A-S-CR>"] = require("telescope").extensions.file_browser.actions.create_from_prompt,
            },
          },
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    })

    -- Enable telescope extensions
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "file_browser")
    pcall(require("telescope").load_extension, "ui-select")
    pcall(require("telescope").load_extension, "undo")

    -- Telescope keymaps matching nixvim
    vim.keymap.set("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", { desc = "File browser" })
    vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>b", require("telescope.builtin").buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "Diagnostics" })
    vim.keymap.set("n", "<C-p>", require("telescope.builtin").git_files, { desc = "Git files" })
    vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "Recent files" })

    -- TODO search
    vim.keymap.set("n", "<C-t>", function()
      require("telescope.builtin").live_grep({
        default_text = "TODO",
        initial_mode = "normal",
      })
    end, { silent = true, desc = "Search TODOs" })
  end,
}
