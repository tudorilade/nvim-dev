-- completion.lua — nvim-cmp (replaces blink.cmp; blink's insert keymap engine kept breaking).
-- Stays in INSERT mode (never select mode). Tab indents unless the popup is open.

return {
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    priority = 1000,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "windwp/nvim-autopairs",
    },
    config = function()
      require("nvim-autopairs").setup({
        check_ts = false,
        disable_filetype = { "TelescopePrompt", "notify", "noice", "lazy", "mason", "help", "qf" },
      })

      local cmp = require("cmp")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      cmp.setup({
        snippet = {
          expand = function() end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp", priority = 1000 } },
          { { name = "path" } },
          { { name = "buffer" } }
        ),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
        },
        enabled = function()
          local ft = vim.bo.filetype
          if ft == "TelescopePrompt" or ft == "notify" or ft == "lazy" or ft == "mason" then
            return false
          end
          return true
        end,
      })

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      vim.api.nvim_create_user_command("CmpReset", function()
        cmp.abort()
        if vim.snippet and vim.snippet.active and vim.snippet.active() then
          vim.snippet.stop()
        end
        vim.notify("Completion reset", vim.log.levels.INFO)
      end, { desc = "Abort completion popup" })
    end,
  },
}
