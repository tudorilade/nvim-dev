-- terminal_nav.lua — open files from terminal output without staying in the term window.

local M = {}

---@param use_line boolean|nil  true for gF-style file:line under cursor
function M.open_from_terminal(use_line)
  if vim.bo.buftype ~= "terminal" then
    if use_line then
      vim.cmd("normal! gF")
    else
      vim.cmd("normal! gf")
    end
    return
  end

  local raw = use_line and vim.fn.expand("<cWORD>") or vim.fn.expand("<cfile>")
  if raw == "" then
    return
  end

  local path, line = raw, nil
  if use_line then
    path, line = raw:match("^(.-):(%d+)$")
    if not path then
      path = vim.fn.expand("<cfile>")
    end
  end

  if path:match(":%d+$") then
    line = tonumber(path:match(":(%d+)$"))
    path = path:sub(1, #path - #tostring(line) - 1)
  end

  path = vim.fn.fnamemodify(path, ":p")
  if vim.fn.filereadable(path) ~= 1 then
    vim.notify("Not a readable file: " .. path, vim.log.levels.WARN)
    return
  end

  -- Close the terminal window; prefer keeping/focusing a normal edit window.
  local term_win = vim.api.nvim_get_current_win()
  local editor_win
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= term_win then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "" then
        editor_win = win
        break
      end
    end
  end

  if editor_win then
    vim.api.nvim_win_close(term_win, true)
    vim.api.nvim_set_current_win(editor_win)
  else
    vim.cmd("close")
  end

  if line then
    vim.cmd("edit +" .. line .. " " .. vim.fn.fnameescape(path))
  else
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end
end

return M
