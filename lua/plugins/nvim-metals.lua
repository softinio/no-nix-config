return {
  "scalameta/nvim-metals",
  lazy = false,
  config = function()
    local metals_config = require("metals").bare_config()
    metals_config.tvp = {
      icons = {
        enabled = true,
      },
    }

    metals_config.settings = {
      -- Build tool settings
      defaultBspToBuildTool = true,
      bloopVersion = "latest.release",

      -- Shell and execution
      defaultShell = "fish",

      -- Features
      enableBestEffort = true,
      enableSemanticHighlighting = true,
      testUserInterface = "Test Explorer",

      -- Excluded packages (Java APIs we don't want)
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
      },

      -- Inlay hints for better code understanding
      inlayHints = {
        typeParameters = { enable = true },
        hintsInPatternMatch = { enable = true },
        inferredTypes = { enable = true },
        implicitArguments = { enable = true },
        implicitConversions = { enable = true },
      },

      -- Claude integration
      mcpClient = "claude",
      startMcpServer = true,

      -- Display options
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = true,
      showInferredType = true,

      -- Code lens features
      superMethodLensesEnabled = true,

      -- Use globally installed metals
      useGlobalExecutable = true,
    }

    metals_config.on_attach = function(client, bufnr)
      -- Metals keybindings are now set in init.lua
      local group = vim.api.nvim_create_augroup("metals-highlight-" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    metals_config.init_options = {
      statusBarProvider = "on",
      compilerOptions = {
        snippetAutoIndent = false,
      },
    }

    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt", "sc", "mill" },
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
