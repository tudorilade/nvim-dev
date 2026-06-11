-- ui.lua — statusline, bufferline (tabs), keybinding hints, indent guides,
-- diagnostics list, TODO highlighting, session restore, and nicer popups.

return {
  -- == which-key: live, searchable keybinding hints ======================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>f", group = "find / file" },
        { "<leader>c", group = "code" },
        { "<leader>h", group = "git hunk" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "split / swap" },
        { "<leader>t", group = "terminal / toggle" },
        { "<leader>b", group = "buffer" },
        { "<leader>r", group = "rename / refactor" },
        { "<leader>x", group = "diagnostics / trouble" },
        { "g", group = "goto" },
        { "]", group = "next" },
        { "[", group = "prev" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer local keymaps" },
    },
  },

  -- == lualine: statusline (mode, git, diagnostics, position) ============
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "NvimTree", "lazy" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype", "encoding" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- == bufferline: visible buffer "tabs" =================================
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
    keys = {
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Buffer 4" },
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    },
  },

  -- == indent guides =====================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      -- Scope uses treesitter and can throw "range (a nil value)" without parsers.
      scope = { enabled = false },
    },
  },

  -- == Trouble: pretty diagnostics / quickfix list ======================
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list (Trouble)" },
    },
  },

  -- == TODO / FIXME / NOTE highlighting + search ========================
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>fT", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
  },

  -- == Session persistence (restore your layout per project) ============
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
  },

  -- == Nicer UI for messages, cmdline, popups ===========================
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- == Startup dashboard ================================================
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      return {
        theme = "doom",
        config = {
          header = {
            "",
            "            nvim-dev            ",
            "   be an extraordinary vimmer   ",
            "",
          },
          center = {
            { icon = "  ", desc = "Find file       ", key = "f", action = "Telescope find_files" },
            { icon = "  ", desc = "Recent files    ", key = "r", action = "Telescope oldfiles" },
            { icon = "  ", desc = "Find text       ", key = "g", action = "Telescope live_grep" },
            { icon = "  ", desc = "Restore session ", key = "s", action = "lua require('persistence').load()" },
            { icon = "  ", desc = "Cheat sheet     ", key = "c", action = function()
              local cfg = vim.fn.resolve(vim.fn.stdpath("config"))
              local doc = vim.fs.normalize(cfg .. "/../docs/02-cheatsheet.md")
              if vim.fn.filereadable(doc) == 1 then vim.cmd("edit " .. vim.fn.fnameescape(doc))
              else vim.notify("Cheat sheet not found at " .. doc, vim.log.levels.WARN) end
            end },
            { icon = "  ", desc = "Quit            ", key = "q", action = "qa" },
          },
        },
      }
    end,
  },
}
