-- completion.lua — blink.cmp: fast autocomplete with snippets.
-- Shows method/function name suggestions from the LSP as you type.

return {
  {
    "saghen/blink.cmp",
    version = "*", -- use a built release (no Rust toolchain needed)
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- Big snippet collection (Python/C++/JS/Rust/etc.) for blink to expand.
      "rafamadriz/friendly-snippets",
    },
    opts = {
      -- Enter accepts; Tab/Up/Down navigate (VS Code-style arrow picking).
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
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
            -- auto_insert closes the menu while ghost text remains; arrows/Enter then
            -- stop working but Tab still does — the "works then breaks" symptom.
            auto_insert = false,
          },
        },
        menu = {
          border = "rounded",
          auto_show = true,
          draw = {},
        },
        documentation = {
          -- Manual only (Ctrl-Space) — avoids redraw errors while Up/Down moves selection.
          auto_show = false,
          treesitter_highlighting = false,
          window = { border = "rounded" },
        },
        ghost_text = {
          enabled = false,
        },
      },

      signature = {
        enabled = true,
        window = {
          border = "rounded",
          treesitter_highlighting = false,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
