-- init.lua — entry point for the nvim-dev configuration.
--
-- Load order matters:
--   1. options  (set leader BEFORE lazy so plugin mappings use the right leader)
--   2. lazy     (bootstrap plugin manager + load lua/plugins/*.lua)
--   3. keymaps  (global, non-plugin keymaps)
--   4. autocmds (filetype tweaks, highlight-on-yank, etc.)
--   5. local    (optional, gitignored machine-specific overrides)

require("config.options")
require("config.clipboard")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.mason_cmd")

-- Optional per-machine overrides (not tracked by git).
pcall(require, "config.local")
