-- autocmds.lua — small quality-of-life automation.

local function augroup(name)
  return vim.api.nvim_create_augroup("nvimdev_" .. name, { clear = true })
end

-- Briefly highlight text when you yank it (visual confirmation).
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Return to the last edit position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-create missing parent directories when saving a new file.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Close some throwaway windows with just `q`.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "qf", "man", "lspinfo", "checkhealth", "notify", "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Trim trailing whitespace on save (skip filetypes where it matters).
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  callback = function()
    local skip = { markdown = true, diff = true }
    if skip[vim.bo.filetype] then return end
    local save = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Terminal buffers: no line numbers, start in insert mode.
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("term_opts"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

-- Python: built-in block-aware indent for `o` / Enter (overrides treesitter).
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("python_indent"),
  pattern = "python",
  priority = 200,
  callback = function()
    vim.bo.autoindent = true
    vim.bo.indentexpr = "GetPythonIndent()"
  end,
})

-- Language-specific indentation overrides (2 spaces for web/lua).
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent_overrides"),
  pattern = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "json", "jsonc", "html", "css", "scss", "lua", "yaml", "markdown",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})
