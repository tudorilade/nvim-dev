-- completion.lua — blink.cmp: fast autocomplete with snippets.
-- Shows method/function name suggestions from the LSP as you type.

return {
  {
    "saghen/blink.cmp",
    version = "*", -- use a built release (no Rust toolchain needed)
    lazy = false,
    priority = 1000,
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        -- "show" reopens the menu if it was dismissed while still completing.
        ["<Up>"] = { "select_prev", "show", "fallback" },
        ["<Down>"] = { "select_next", "show", "fallback" },
        ["<C-n>"] = { "select_next", "show", "fallback" },
        ["<C-p>"] = { "select_prev", "show", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "cancel", "hide", "fallback" },
        ["<C-y>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "accept", "select_and_accept", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },
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

      -- Off: signature float + LSP insert maps fought blink menu keymaps.
      signature = { enabled = false },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
