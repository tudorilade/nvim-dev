-- completion_fix.lua — keep blink.cmp insert keymaps alive.
-- Other plugins (autopairs, floats, notifications) can overwrite <CR>/<Up>/<Down>
-- mid-session; blink only re-adds missing maps on ModeChanged, so we repair often.

local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("nvimdev_blink_repair", { clear = true })

  local function repair()
    if vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "" then
      return
    end
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= "i" and mode ~= "s" then
      return
    end
    pcall(require("blink.cmp.keymap").ensure_mappings)
  end

  local scheduled_repair = vim.schedule_wrap(repair)

  vim.api.nvim_create_autocmd({ "InsertEnter", "ModeChanged" }, {
    group = group,
    callback = scheduled_repair,
  })

  -- Repair after edits — cheap no-op when keymaps are intact.
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    callback = scheduled_repair,
  })
end

return M
