-- editor.lua — editing superpowers: multi-cursor, word exchange, on-screen
-- jumps, surround, comments, autopairs, and handy text objects.

return {
  -- == Multiple cursors (VS Code Ctrl-D style) ============================
  -- Ctrl-d = add next matching word (like VS Code "Add Selection To Next Find Match")
  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = {
      { "<C-d>", mode = { "n", "x" }, desc = "Multi-cursor: next match (VS Code Ctrl-D)" },
      { "<C-S-d>", mode = { "n", "x" }, desc = "Multi-cursor: select all matches" },
      { "<C-Down>", mode = { "n", "x" }, desc = "Multi-cursor: add cursor down" },
      { "<C-Up>", mode = { "n", "x" }, desc = "Multi-cursor: add cursor up" },
    },
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
        ["Add Cursor Down"] = "<C-Down>",
        ["Add Cursor Up"] = "<C-Up>",
        ["Select All"] = "<C-S-d>",
        ["Skip Region"] = "<leader>u",
        ["Remove Region"] = "<leader>p",
      }
      vim.g.VM_theme = "ocean"
      vim.g.VM_set_statusline = 0
      vim.g.VM_silent_exit = 1
    end,
  },

  -- == Exchange / swap two pieces of text =================================
  -- Workflow: put cursor on first word -> cxiw, on second word -> cxiw.
  -- They swap. `cxx` exchanges whole lines; `X` exchanges a visual selection.
  {
    "tommcdo/vim-exchange",
    keys = {
      { "cx", mode = "n", desc = "Exchange (operator)" },
      { "cxx", mode = "n", desc = "Exchange line" },
      { "cxc", mode = "n", desc = "Cancel exchange" },
      { "X", mode = "x", desc = "Exchange selection" },
    },
  },

  -- == Flash: jump anywhere on screen in 2-3 keystrokes ==================
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = { char = { jump_labels = true } },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
    },
  },

  -- == Surround: add/change/delete brackets, quotes, tags =================
  -- ysiw" -> surround word with quotes; cs"' -> change " to '; ds" -> delete.
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- == Comments: gcc line, gc in visual, gcap paragraph ==================
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Context-aware comment strings (correct comments inside JSX, etc.).
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },

  -- == Autopairs: auto-close brackets/quotes =============================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "saghen/blink.cmp" },
    opts = {
      check_ts = false,
      -- blink.cmp owns <CR> (accept + auto_brackets). map_cr steals Enter later.
      map_cr = false,
    },
  },

  -- == Better around/inside text objects (ai, ii, etc.) ==================
  -- Adds powerful text objects: function args, quotes, brackets via `a`/`i`.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ a = { "@block.outer", "@conditional.outer", "@loop.outer" }, i = { "@block.inner", "@conditional.inner", "@loop.inner" } }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        },
      }
    end,
  },
}
