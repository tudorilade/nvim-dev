-- colorscheme.lua — dark, blue, easy on the eyes.
-- Default: tokyonight "storm" (deep blue). Alternatives are installed and
-- documented so you can switch with <leader>ft or by editing this file.

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- load before everything else so UI starts themed
    opts = {
      style = "storm", -- "storm" (blue), "moon" (darker blue), "night", "day"
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark",
      },
      dim_inactive = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-storm")
    end,
  },

  -- Alternative themes (not active, but ready to pick via <leader>ft).
  { "rebelot/kanagawa.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
}
