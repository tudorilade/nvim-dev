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
      -- Keymap preset: Enter to accept, Tab/S-Tab to navigate, Ctrl-Space to
      -- open. "super-tab" makes Tab both accept and jump snippet placeholders.
      keymap = {
        preset = "super-tab",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = {
          border = "rounded",
          draw = { treesitter = { "lsp" } },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true }, -- inline preview of the top suggestion
      },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      -- Rust fuzzy matcher prebuilt binary downloaded by the release version.
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
