return {
  -- nvim-lspconfig still provides useful server defaults (cmd, filetypes, root_dir)
  -- but we're using native vim.lsp.config() API instead of lspconfig.setup()
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Useful status updates for LSP
    "j-hui/fidget.nvim",

    -- schemas for json and yaml files
    "b0o/schemastore.nvim",
  },
  config = function()
    -- Enable inlay hints
    vim.lsp.inlay_hint.enable(true)

    -- Enable diagnostic virtual text
    vim.diagnostic.config({
      virtual_text = true,
    })

    -- Setup LSP keybindings via LspAttach autocommand (replaces on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(args)
        local bufnr = args.buf

        -- Helper function for setting keymaps
        local nmap = function(keys, func, desc)
          if desc then
            desc = "LSP: " .. desc
          end
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        -- LSP keymaps matching nixvim
        nmap("gd", vim.lsp.buf.definition, "Go to definition")
        nmap("gD", require("telescope.builtin").lsp_references, "Go to references")
        nmap("gt", vim.lsp.buf.type_definition, "Go to type definition")
        nmap("gi", vim.lsp.buf.implementation, "Go to implementation")
        nmap("K", vim.lsp.buf.hover, "Hover documentation")
        nmap("<F2>", vim.lsp.buf.rename, "Rename")

        -- Additional useful LSP keymaps
        nmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
        nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document symbols")
        nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
        nmap("<C-k>", vim.lsp.buf.signature_help, "Signature help")
        nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace add folder")
        nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace remove folder")
        nmap("<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "Workspace list folders")

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
          vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
      end,
    })

    -- nvim-cmp supports additional completion capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    -- Server settings table (nvim-lspconfig provides default cmd/filetypes/root_dir)
    local servers = {
      -- Python
      basedpyright = {
        basedpyright = {
          analysis = {
            autoImportCompletions = true,
            autoSearchPaths = true,
            inlayHints = {
              callArgumentNames = true,
            },
            diagnosticMode = "openFilesOnly",
            reportMissingImports = true,
            reportMissingParameterType = true,
            reportUnnecessaryComparison = true,
            reportUnnecessaryContains = true,
            reportUnusedClass = true,
            reportUnusedFunction = true,
            reportUnsedImports = true,
            reportUnsusedVariables = true,
            typeCheckingMode = "recommended",
            useLibraryCodeForTypes = true,
          },
        },
      },
      -- Shell scripting
      bashls = {},
      -- Web development
      html = {},
      jsonls = {
        json = {
          format = {
            enable = true,
          },
          schemas = require("schemastore").json.schemas(),
          validate = true,
        },
      },
      ts_ls = {},
      yamlls = {},
      -- Query languages
      jqls = {},
      -- Lua
      lua_ls = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
      -- Documentation
      marksman = {},
      -- Nix
      nil_ls = {},
      nixd = {},
      -- Python pyrefly
      pyrefly = {},
      -- Rust
      rust_analyzer = {},
      -- Swift/iOS
      sourcekit = {},
      -- Typst
      tinymist = {},
      -- Zig
      zls = {},
    }

    -- Configure and enable each server using native vim.lsp.config() API
    -- nvim-lspconfig provides default configs (cmd, filetypes, root_dir)
    -- We only need to extend with capabilities and settings
    for server, settings in pairs(servers) do
      vim.lsp.config(server, {
        capabilities = capabilities,
        settings = settings,
      })

      -- Enable this server (activates for its filetypes)
      vim.lsp.enable(server)
    end
  end,
}
