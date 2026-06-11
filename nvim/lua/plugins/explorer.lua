-- explorer.lua — file tree you can drive entirely from the keyboard.

return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
      { "<leader>o", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal file in explorer" },
    },
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 36, side = "left" },
      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = { enable = true },
      },
      filters = { dotfiles = false, custom = { "^.git$", "node_modules", "__pycache__" } },
      git = { enable = true, ignore = false },
      actions = { open_file = { quit_on_open = false, window_picker = { enable = false } } },
      update_focused_file = { enable = true },
      -- Within the tree: a=create, d=delete, r=rename, x=cut, c=copy, p=paste,
      -- <CR>=open, o=open, <C-v>=vsplit, <C-x>=split, R=refresh, H=toggle hidden.
    },
  },
}
