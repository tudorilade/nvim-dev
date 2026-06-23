-- completion.lua — blink.cmp: fast autocomplete with snippets.
-- Keymaps are snippet-aware: stuck snippet placeholders were breaking Enter/arrows
-- while Tab still worked (snippet_forward).

local function not_snippet(cmp, action)
  if cmp.snippet_active() then
    return false
  end
  return action(cmp)
end

return {
  {
    "saghen/blink.cmp",
    version = "*",
    lazy = false,
    priority = 1000,
    dependencies = {},
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_forward()
            end
            return cmp.select_next()
          end,
          function(cmp)
            return not_snippet(cmp, function(c) return c.show() end)
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_backward()
            end
            return cmp.select_prev()
          end,
          "fallback",
        },
        ["<Up>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_backward()
            end
            return cmp.select_prev()
          end,
          function(cmp)
            return not_snippet(cmp, function(c) return c.show() end)
          end,
          "fallback",
        },
        ["<Down>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_forward()
            end
            return cmp.select_next()
          end,
          function(cmp)
            return not_snippet(cmp, function(c) return c.show() end)
          end,
          "fallback",
        },
        ["<C-n>"] = {
          function(cmp)
            return not_snippet(cmp, function(c) return c.select_next() end)
          end,
          "show",
          "fallback",
        },
        ["<C-p>"] = {
          function(cmp)
            return not_snippet(cmp, function(c) return c.select_prev() end)
          end,
          "show",
          "fallback",
        },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "cancel", "hide", "fallback" },
        ["<C-y>"] = {
          function(cmp)
            return not_snippet(cmp, function(c) return c.select_and_accept() end)
          end,
          "fallback",
        },
        ["<CR>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_forward()
            end
            if cmp.is_menu_visible() then
              return cmp.accept()
            end
            return cmp.select_and_accept()
          end,
          "fallback",
        },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },
        trigger = {
          show_in_snippet = false,
        },
        list = {
          selection = {
            preselect = function()
              return not require("blink.cmp").snippet_active({ direction = 1 })
            end,
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
