-- treesitter.lua — parsers, highlighting, indentation, and text objects.
-- Neovim 0.12+ requires nvim-treesitter `main` (master is frozen for 0.11).

local function ts_cli_available()
  return vim.fn.executable("tree-sitter") == 1
end

local function notify_missing_cli()
  vim.notify(
    "tree-sitter CLI not found — run ./setup.sh (or install tree-sitter to ~/.local/bin). "
      .. "Syntax highlighting and parser installs are disabled until then.",
    vim.log.levels.WARN
  )
end

local function ensure_parser(lang)
  if not lang or lang == "" or not ts_cli_available() then
    return
  end
  local ok_cfg, cfg = pcall(require, "nvim-treesitter.config")
  if not ok_cfg then
    return
  end
  if vim.tbl_contains(cfg.get_installed(), lang) then
    return
  end
  pcall(require("nvim-treesitter").install, { lang })
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- required by the plugin
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSInstall", "TSUninstall", "TSLog" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if ft == "" then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft)
          ensure_parser(lang)

          pcall(vim.treesitter.start, args.buf)
          if lang and ts_cli_available() then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          if not ts_cli_available() then
            notify_missing_cli()
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
      local ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
      if not ok or type(textobjects.setup) ~= "function" then
        vim.notify(
          "nvim-treesitter-textobjects is outdated — run :Lazy sync (needs main branch).",
          vim.log.levels.WARN
        )
        return
      end

      textobjects.setup({
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
