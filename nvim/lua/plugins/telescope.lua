-- telescope.lua — fuzzy finder: files, live grep, buffers, symbols, help.
-- This powers the "grep the project, browse, open at line in ~4 keystrokes"
-- workflow as well as mouse-free file/buffer navigation.

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Native fzf sorter (compiled) for fast matching.
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      -- VS Code Ctrl+P — buffers open in this session (MRU order).
      { "<C-p>", "<cmd>Telescope buffers<cr>", mode = "n", desc = "Open buffers (Ctrl+P)" },

      -- Files & buffers
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fa", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find all files (hidden)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader><space>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },

      -- The headline grep workflow.
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep (project)" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", mode = "v", desc = "Grep selection" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in current buffer" },

      -- Helpers
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics (workspace)" },
      { "<leader>ft", "<cmd>Telescope colorscheme<cr>", desc = "Theme picker" },
      { "<leader>fR", "<cmd>Telescope resume<cr>", desc = "Resume last picker" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.90,
            height = 0.85,
          },
          mappings = {
            i = {
              -- Browse results from the prompt without leaving insert mode.
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              -- Send everything to the quickfix list (grep -> quickfix).
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              -- Open in splits/tabs.
              ["<C-v>"] = actions.select_vertical,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<Esc>"] = actions.close, -- single Esc closes the picker
            },
          },
          file_ignore_patterns = {
            "%.git/", "node_modules/", "%.venv/", "venv/", "__pycache__/",
            "target/", "dist/", "build/", "%.o", "%.a", "%.out",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob", "!**/.git/*",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = vim.fn.executable("fd") == 1
              and { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
              or nil,
          },
          buffers = {
            sort_mru = true,
            ignore_current_buffer = false,
            show_all_buffers = true,
            mappings = {
              i = {
                ["<C-d>"] = actions.delete_buffer,
                -- Arrow keys (VS Code-style) in addition to Ctrl-j/k.
                ["<Up>"] = actions.move_selection_previous,
                ["<Down>"] = actions.move_selection_next,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
  },
}
