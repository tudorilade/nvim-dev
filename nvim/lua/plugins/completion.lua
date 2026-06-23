-- completion.lua — blink.cmp autocomplete.
--
-- Rules:
--   Tab  = indent (Python) UNLESS menu is open OR a real vim.snippet session is active
--   Up/Down / Enter = completion ONLY when the menu is visible
--   Ctrl-g Ctrl-e or :CmpReset = hard reset when stuck

return {
  {
    "saghen/blink.cmp",
    version = "*",
    lazy = false,
    priority = 1000,
    opts = {
      keymap = {
        preset = "enter",
        -- Enter preset Tab = snippet + indent fallback. We only add menu navigation.
        ["<Tab>"] = {
          function(cmp)
            if vim.snippet.active() then
              return cmp.snippet_forward()
            end
            if cmp.is_menu_visible() then
              return cmp.select_next()
            end
            return false
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if vim.snippet.active() then
              return cmp.snippet_backward()
            end
            if cmp.is_menu_visible() then
              return cmp.select_prev()
            end
            return false
          end,
          "fallback",
        },
        ["<Up>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_prev()
            end
            return false
          end,
          "fallback",
        },
        ["<Down>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_next()
            end
            return false
          end,
          "fallback",
        },
        ["<C-n>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_next()
            end
            return cmp.show()
          end,
          "fallback",
        },
        ["<C-p>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_prev()
            end
            return cmp.show()
          end,
          "fallback",
        },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = {
          function()
            require("config.completion_fix").reset()
            return false
          end,
          "fallback",
        },
        ["<C-y>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_and_accept()
            end
            return false
          end,
          "fallback",
        },
        ["<CR>"] = {
          function(cmp)
            if vim.snippet.active() then
              return cmp.snippet_forward()
            end
            if cmp.is_menu_visible() then
              return cmp.accept()
            end
            return false
          end,
          "fallback",
        },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      snippets = {
        -- blink's snippet_active() can lie after LSP accepts; trust vim.snippet only.
        active = function()
          return vim.snippet.active()
        end,
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },
        trigger = {
          show_in_snippet = false,
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        menu = {
          border = "rounded",
          auto_show = true,
          draw = {},
        },
        documentation = {
          auto_show = false,
          treesitter_highlighting = false,
          window = { border = "rounded" },
        },
        ghost_text = {
          enabled = false,
        },
      },

      signature = { enabled = false },

      sources = {
        default = { "lsp", "path", "buffer" },
        transform_items = function(_, items)
          local kind = require("blink.cmp.types").CompletionItemKind.Snippet
          return vim.tbl_filter(function(item)
            return item.kind ~= kind
          end, items)
        end,
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      require("blink.cmp").setup(opts)
      require("config.completion_fix").setup()
    end,
  },
}
