-- lsp.lua — language servers (autocomplete, go-to-definition, diagnostics)
-- plus Mason for installing them, and conform.nvim for formatting.

-- Which LSP servers to install + enable. Keys are mason-lspconfig server names.
-- Languages requested: Python, C/C++, JS/TS + web, Rust, Lua, Bash.
local servers = {
  basedpyright = {                 -- Python (fast pyright fork)
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "basic",
          autoImportCompletions = true,
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  },
  -- Ruff: format/lint via conform + Mason tools (not a second Python LSP).
  clangd = {                        -- C / C++
    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
  },
  ts_ls = {},                       -- JavaScript / TypeScript
  html = {},
  cssls = {},
  jsonls = {},
  rust_analyzer = {                 -- Rust
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
      },
    },
  },
  lua_ls = {                        -- Lua (configured for Neovim dev)
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
        hint = { enable = true },
      },
    },
  },
  bashls = {},                      -- Bash / shell
}

-- Extra tools (formatters/linters) installed via Mason but not LSP servers.
local extra_tools = {
  "stylua",        -- Lua formatter
  "prettier",      -- JS/TS/HTML/CSS/JSON/Markdown formatter
  "clang-format",  -- C/C++ formatter
  "shfmt",         -- shell formatter
  "ruff",          -- Python linter/formatter (conform: ruff_format)
  "black",         -- Python formatter fallback
}

return {
  -- == Mason: installer for LSP servers, formatters, linters ==============
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded", icons = {
        package_installed = "✓", package_pending = "➜", package_uninstalled = "✗",
      } },
    },
  },

  -- == LSP configuration ==================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "j-hui/fidget.nvim", opts = {} }, -- LSP progress UI (bottom right)
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
      end
      capabilities.textDocument.completion.completionItem.snippetSupport = false

      -- Neovim 0.11+ native LSP config. Apply capabilities to ALL servers,
      -- then layer each server's specific overrides on top. mason-lspconfig
      -- (v2) then auto-enables every installed server via vim.lsp.enable.
      vim.lsp.config("*", { capabilities = capabilities })
      for name, cfg in pairs(servers) do
        if next(cfg) ~= nil then
          vim.lsp.config(name, cfg)
        end
      end

      -- Per-buffer keymaps and hooks — run once per buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("nvimdev_lsp_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          if vim.b[buf].nvimdev_lsp_setup then
            return
          end
          vim.b[buf].nvimdev_lsp_setup = true

          local function lmap(keys, fn, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, fn, { buffer = buf, desc = "LSP: " .. desc, silent = true })
          end

          local function client_supports(client, method)
            return client and type(client.supports_method) == "function" and client:supports_method(method)
          end

          -- Navigation. gd opens the file (if elsewhere) and adds a jumplist
          -- entry, so Ctrl-o / Alt-Left jumps back exactly like VS Code.
          lmap("gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, "Go to definition")
          lmap("gD", vim.lsp.buf.declaration, "Go to declaration")
          lmap("gr", function() require("telescope.builtin").lsp_references() end, "References")
          lmap("gi", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, "Go to implementation")
          lmap("gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, "Type definition")

          -- Docs and help.
          lmap("K", vim.lsp.buf.hover, "Hover documentation")
          lmap("gK", vim.lsp.buf.signature_help, "Signature help")

          -- Refactor.
          lmap("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          lmap("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })

          -- Symbols.
          lmap("<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, "Document symbols")
          lmap("<leader>fS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Workspace symbols")

          -- Diagnostics.
          lmap("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          lmap("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
          lmap("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")

          -- Inlay hints (always register; harmless if server lacks support).
          lmap("<leader>th", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
          end, "Toggle inlay hints")

          -- Highlight references once any attached server supports it (py = 2 clients).
          vim.schedule(function()
            if vim.b[buf].nvimdev_lsp_highlight_setup then
              return
            end
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
              if client_supports(c, "textDocument/documentHighlight") then
                vim.b[buf].nvimdev_lsp_highlight_setup = true
                local hl_group = vim.api.nvim_create_augroup("nvimdev_lsp_highlight_" .. buf, { clear = true })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                  buffer = buf,
                  group = hl_group,
                  callback = vim.lsp.buf.document_highlight,
                })
                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                  buffer = buf,
                  group = hl_group,
                  callback = vim.lsp.buf.clear_references,
                })
                break
              end
            end
          end)
        end,
      })

      -- mason-lspconfig (v2): install the servers and auto-enable them using
      -- the native vim.lsp.enable mechanism (automatic_enable defaults to true).
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      -- mason-tool-installer; :MasonInstallAll is registered in config/mason_cmd.lua
      require("mason-tool-installer").setup({
        ensure_installed = extra_tools,
        auto_update = false,
        run_on_start = false,
      })
    end,
  },

  -- == Formatting: conform.nvim (format on save) =========================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black" }, -- ruff via Mason tool, not ruff LSP
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      format_on_save = function(bufnr)
        -- Allow disabling via :FormatDisable (buffer or global).
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1500, lsp_format = "fallback" }
      end,
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      -- Toggle commands for format-on-save.
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
      end, { desc = "Disable autoformat-on-save", bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable autoformat-on-save" })
    end,
  },
}
