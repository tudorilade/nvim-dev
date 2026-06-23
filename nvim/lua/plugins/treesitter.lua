-- treesitter.lua — parsers, highlighting, indentation, and text objects.
-- Neovim 0.12+ requires nvim-treesitter `main` (master is frozen for 0.11).

local function ts_cli_works()
  if vim.fn.executable("tree-sitter") ~= 1 then
    return false
  end
  local out = vim.fn.system({ "tree-sitter", "--version" })
  if vim.v.shell_error ~= 0 then
    return false
  end
  return not out:match("GLIBC") and not out:match("cannot open shared object")
end

local function notify_missing_cli()
  vim.notify(
    "tree-sitter CLI missing or incompatible (common on Ubuntu 22.04 — needs older build or cargo install). "
      .. "Syntax highlighting via treesitter is disabled; everything else still works.",
    vim.log.levels.WARN
  )
end

-- UI / plugin buffers — never run treesitter or TSInstall on these.
-- (notify popups were triggering "skipping unsupported language: notify" and
-- breaking insert-mode completion keymaps.)
local skip_ft = {
  notify = true,
  noice = true,
  lazy = true,
  mason = true,
  alpha = true,
  dashboard = true,
  TelescopePrompt = true,
  NvimTree = true,
  ["neo-tree"] = true,
  help = true,
  qf = true,
  startuptime = true,
  checkhealth = true,
  lspinfo = true,
  cmp_menu = true,
  blink_cmp_menu = true,
  DressingInput = true,
  minifiles = true,
  gitcommit = true,
  fugitive = true,
}

-- Project languages only — never call TSInstall for random plugin filetypes.
local auto_install = {
  python = true,
  lua = true,
  vim = true,
  vimdoc = true,
  javascript = true,
  typescript = true,
  tsx = true,
  c = true,
  cpp = true,
  rust = true,
  bash = true,
  html = true,
  css = true,
  json = true,
  jsonc = true,
  markdown = true,
  yaml = true,
}

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
  if native_indent[ft] or skip_ft[ft] then
    return false
  end
  if not ts_cli_works() or not lang then
    return false
  end
  return parser_installed(lang)
end

local function ensure_parser(lang)
  if not lang or lang == "" or not auto_install[lang] or not ts_cli_works() then
    return
  end
  if parser_installed(lang) then
    return
  end
  pcall(require("nvim-treesitter").install, { lang })
end

local function ts_start(buf, ft)
  if skip_ft[ft] or ft == "" then
    return
  end
  local lang = vim.treesitter.language.get_lang(ft)
  if not lang then
    return
  end
  -- Only attach when a parser already exists — never TSInstall notify/cmp_menu/etc.
  local ok, added = pcall(vim.treesitter.language.add, lang)
  if not ok or not added then
    return
  end
  pcall(vim.treesitter.start, buf)
end

local function vim_queries_ok()
  return pcall(vim.treesitter.query.get, "vim", "highlights")
end

local function ensure_vim_parsers()
  if not ts_cli_works() then
    return
  end
  if parser_installed("vim") and parser_installed("vimdoc") and vim_queries_ok() then
    return
  end
  pcall(function()
    require("nvim-treesitter").install({ "vim", "vimdoc" }):wait(120000)
  end)
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
    cmd = { "TSUpdate", "TSInstall", "TSUninstall", "TSLog" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if skip_ft[ft] or ft == "" then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft)
          ensure_parser(lang)
          ts_start(args.buf, ft)

          if use_ts_indent(ft, lang) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          if not ts_cli_works() then
            notify_missing_cli()
          elseif not vim_queries_ok() then
            ensure_vim_parsers()
          end
        end,
      })

      -- After treesitter FileType hook: restore Python's built-in indent (`o` / Enter).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          vim.bo.autoindent = true
          vim.bo.indentexpr = "GetPythonIndent()"
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
