-- git.lua — git integration: inline hunk signs/staging + lazygit UI.

return {
  -- == Gitsigns: gutter signs, stage/reset/preview hunks, blame ==========
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = false,
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = "Git: " .. desc })
        end

        -- Navigate hunks.
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

        -- Stage / reset / preview.
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
      end,
    },
  },

  -- == Lazygit: full TUI for commits, branches, rebases =================
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "Lazygit (current file)" },
    },
  },
}
