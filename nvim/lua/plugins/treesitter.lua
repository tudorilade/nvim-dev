-- treesitter.lua — accurate syntax highlighting, indentation, and text objects.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- classic API (the new `main` branch has a different API)
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "c", "cpp", "python", "rust", "lua", "luadoc", "bash",
        "javascript", "typescript", "tsx", "html", "css", "json", "jsonc",
        "yaml", "toml", "markdown", "markdown_inline", "vim", "vimdoc",
        "regex", "diff", "gitcommit", "gitignore", "dockerfile",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- store in jumplist so Ctrl-o works
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        },
        swap = {
          enable = true,
          swap_next = { ["<leader>na"] = "@parameter.inner" },
          swap_previous = { ["<leader>pa"] = "@parameter.inner" },
        },
      },
    },
  },
}
