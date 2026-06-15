-- terminal.lua — integrated terminal (Emacs-like).
-- Toggle with Ctrl-\. Inside it, press <Esc><Esc> to enter terminal-normal
-- mode where you can scroll with j/k, search output with / and n, and yank
-- text like any other buffer. Run `grep -rn "text"` and it starts from the
-- current working directory.

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal)" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (vertical)" },
      { "<leader>tg", desc = "Lazygit terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = { border = "rounded", width = function() return math.floor(vim.o.columns * 0.85) end, height = function() return math.floor(vim.o.lines * 0.8) end },
      size = function(term)
        if term.direction == "horizontal" then return 15
        elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4) end
      end,
      shade_terminals = true,
      start_in_insert = true,
      persist_mode = false,
      persist_size = true,
      -- Start each terminal in the directory of the current file's project.
      autochdir = false,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- A dedicated lazygit terminal (full screen, project root).
      local ok, Terminal = pcall(function() return require("toggleterm.terminal").Terminal end)
      if ok then
        local lazygit = Terminal:new({
          cmd = "lazygit",
          direction = "float",
          float_opts = { border = "rounded" },
          hidden = true,
        })
        vim.keymap.set("n", "<leader>tg", function()
          if vim.fn.executable("lazygit") == 1 then
            lazygit:toggle()
          else
            vim.notify("lazygit not installed", vim.log.levels.WARN)
          end
        end, { desc = "Lazygit terminal" })
      end

      local terminal_nav = require("config.terminal_nav")

      -- Terminal buffer maps (normal mode after <Esc><Esc> from terminal insert).
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function(event)
          local o = { buffer = event.buf, silent = true }
          vim.keymap.set("n", "gf", function()
            terminal_nav.open_from_terminal(false)
          end, vim.tbl_extend("force", o, { desc = "Go to file (close terminal)" }))
          vim.keymap.set("n", "gF", function()
            terminal_nav.open_from_terminal(true)
          end, vim.tbl_extend("force", o, { desc = "Go to file:line (close terminal)" }))
          vim.keymap.set("n", "<C-p>", "<cmd>Telescope buffers<cr>", vim.tbl_extend("force", o, { desc = "Open buffers (Ctrl+P)" }))
        end,
      })

      -- Extra terminal-mode conveniences (window nav straight from terminal).
      vim.api.nvim_create_autocmd("TermEnter", {
        callback = function()
          local o = { buffer = 0, silent = true }
          vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
          vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], o)
          vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
          vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], o)
        end,
      })
    end,
  },
}
