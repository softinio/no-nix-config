return {
  "hrsh7th/nvim-cmp",
  -- load cmp on InsertEnter
  event = "InsertEnter",
  -- these dependencies will only be loaded when cmp loads
  -- dependencies are always lazy-loaded unless specified otherwise
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lsp-document-symbol",
    "davidsierradz/cmp-conventionalcommits",
    "petertriho/cmp-git",
    "mtoohey31/cmp-fish",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Update completeopt
    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    -- Setup lspkind
    lspkind.init({
      mode = "symbol_text",
      symbol_map = {},
    })

    cmp.setup({
      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 200,
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        {
          name = "buffer",
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          },
        },
        { name = "path" },
        { name = "nvim_lua" },
        { name = "nvim_lsp_signature_help" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
          menu = {
            nvim_lsp = "[LSP]",
            luasnip = "[snip]",
            buffer = "[buffer]",
            path = "[path]",
            nvim_lua = "[api]",
          },
        }),
      },
    })

    -- Setup for git commits
    cmp.setup.filetype("gitcommit", {
      sources = cmp.config.sources({
        { name = "git" },
        { name = "conventionalcommits" },
      }, {
        { name = "buffer" },
      }),
    })

    -- Configure cmp-git
    require("cmp_git").setup()

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
