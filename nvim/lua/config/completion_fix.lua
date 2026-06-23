-- completion_fix.lua — reset stuck blink/snippet state; repair keymaps on insert.

local M = {}

--- Hard reset: close menu, kill zombie snippet session, restore keymaps.
function M.reset()
  pcall(function()
    local cmp = require("blink.cmp")
    cmp.cancel()
    cmp.hide()
  end)

  if vim.snippet and vim.snippet.active and vim.snippet.active() then
    vim.snippet.stop()
  end

  pcall(require("blink.cmp.keymap").ensure_mappings)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("nvimdev_blink_repair", { clear = true })

  vim.api.nvim_create_user_command("CmpReset", function()
    M.reset()
    vim.notify("Autocomplete reset (Tab = indent again)", vim.log.levels.INFO)
  end, { desc = "Reset stuck blink.cmp / snippet session" })

  -- Ctrl-g Ctrl-e — "get me out" (works when Ctrl-e alone does not).
  vim.keymap.set("i", "<C-g><C-e>", function()
    M.reset()
  end, { desc = "Reset autocomplete (unstick Tab)" })

  -- Snippet sessions survive too long without this (blink issue #1805).
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      if vim.snippet and vim.snippet.active and vim.snippet.active() then
        vim.snippet.stop()
      end
    end,
  })

  local function repair()
    if vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "" then
      return
    end
    local mode = vim.api.nvim_get_mode().mode
    if mode == "i" or mode == "s" then
      pcall(require("blink.cmp.keymap").ensure_mappings)
    end
  end

  vim.api.nvim_create_autocmd({ "InsertEnter", "ModeChanged" }, {
    group = group,
    callback = vim.schedule_wrap(repair),
  })
end

return M
