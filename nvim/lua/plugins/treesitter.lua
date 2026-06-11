-- treesitter.lua — parsers, highlighting, indentation, and text objects.
-- Neovim 0.12+ requires nvim-treesitter `main` (master is frozen for 0.11).

local parsers = {
  "c", "cpp", "python", "rust", "lua", "luadoc", "bash",
  "javascript", "typescript", "tsx", "html", "css", "json", "jsonc",
  "yaml", "toml", "markdown", "markdown_inline", "vim", "vimdoc",
  "regex", "diff", "gitcommit", "gitignore", "dockerfile",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- required by the plugin
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSInstall", "TSUninstall", "TSLog" },
    init = function()
      -- Highlight + indent via treesitter (replaces old configs.setup options).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Install any missing parsers after lazy finishes loading plugins.
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          local ok, ts = pcall(require, "nvim-treesitter")
          if not ok then return end
          local ok_cfg, cfg = pcall(require, "nvim-treesitter.config")
          if not ok_cfg then return end
          local installed = cfg.get_installed()
          local missing = vim.tbl_filter(function(p)
            return not vim.tbl_contains(installed, p)
          end, parsers)
          if #missing > 0 then
            ts.install(missing)
          end
        end,
      })
    end,
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local function sel(lhs, query)
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      sel("af", "@function.outer")
      sel("if", "@function.inner")
      sel("ac", "@class.outer")
      sel("ic", "@class.inner")
      sel("aa", "@parameter.outer")
      sel("ia", "@parameter.inner")
      sel("al", "@loop.outer")
      sel("il", "@loop.inner")
      sel("ai", "@conditional.outer")
      sel("ii", "@conditional.inner")

      local function mv(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          fn(query, "textobjects")
        end, { desc = desc })
      end

      mv("]f", move.goto_next_start, "@function.outer", "Next function start")
      mv("[f", move.goto_previous_start, "@function.outer", "Prev function start")
      mv("]c", move.goto_next_start, "@class.outer", "Next class start")
      mv("[c", move.goto_previous_start, "@class.outer", "Prev class start")
      mv("]a", move.goto_next_start, "@parameter.inner", "Next parameter")
      mv("[a", move.goto_previous_start, "@parameter.inner", "Prev parameter")

      vim.keymap.set("n", "<leader>na", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap parameter with next" })
      vim.keymap.set("n", "<leader>pa", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap parameter with prev" })
    end,
  },
}
