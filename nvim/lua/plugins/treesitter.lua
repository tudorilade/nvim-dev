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

-- Languages with reliable built-in Neovim indent — never override with treesitter.
local native_indent = {
  python = true,
  lua = true,
  vim = true,
  help = true,
}

local function parser_installed(lang)
  if not lang then
    return false
  end
  local ok_cfg, cfg = pcall(require, "nvim-treesitter.config")
  if not ok_cfg then
    return false
  end
  return vim.tbl_contains(cfg.get_installed(), lang)
end

local function use_ts_indent(ft, lang)
  if native_indent[ft] then
    return false
  end
  if not ts_cli_available() or not lang then
    return false
  end
  return parser_installed(lang)
end

local function ensure_parser(lang)
  if not lang or lang == "" or not ts_cli_available() then
    return
  end
  if parser_installed(lang) then
    return
  end
  pcall(require("nvim-treesitter").install, { lang })
end

local function setup_textobjects()
  local textobjects = require("nvim-treesitter-textobjects")
  if type(textobjects.setup) ~= "function" then
    error(
      "wrong plugin version (master branch still installed?) — "
        .. "quit nvim, run: rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects && nvim +'Lazy sync'"
    )
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
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    -- Do not `:TSUpdate` all parsers on every Lazy sync (slow + flaky on locked-down hosts).
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
          if use_ts_indent(ft, lang) then
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
    commit = "851e865342e5a4cb1ae23d31caf6e991e1c99f1e",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ok, err = pcall(setup_textobjects)
      if not ok then
        vim.notify("nvim-treesitter-textobjects: " .. err, vim.log.levels.ERROR)
      end
    end,
  },
}
