-- clipboard.lua — laptop clipboard over SSH (OSC 52), WSL, or local xclip.

local opt = vim.opt

local function is_ssh_session()
  return (vim.env.SSH_TTY and vim.env.SSH_TTY ~= "")
    or (vim.env.SSH_CONNECTION and vim.env.SSH_CONNECTION ~= "")
    or (vim.env.SSH_CLIENT and vim.env.SSH_CLIENT ~= "")
end

-- WSL → Windows clipboard.
if vim.fn.has("wsl") == 1 and vim.fn.executable("win32yank.exe") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
  opt.clipboard = "unnamedplus"
elseif is_ssh_session() then
  -- SSH: never use remote xclip — forward yanks to the laptop via the terminal.
  -- Neovim 0.12: string form enables bundled OSC 52 provider.
  vim.g.clipboard = "osc52"
  opt.clipboard = "unnamedplus"

  -- Hint terminals / multiplexers that may not auto-detect OSC 52.
  local tf = vim.g.termfeatures or {}
  if tf.osc52 == nil then
    tf.osc52 = true
    vim.g.termfeatures = tf
  end
elseif vim.fn.has("clipboard") == 1 then
  if vim.fn.executable("xclip") == 1
    or vim.fn.executable("xsel") == 1
    or vim.fn.executable("wl-copy") == 1
    or vim.fn.executable("pbcopy") == 1
    or vim.fn.executable("clip") == 1
  then
    opt.clipboard = "unnamedplus"
  end
end

-- Explicit copy to laptop clipboard (SSH): `gy` / `gyy` in normal, `gy` in visual.
if is_ssh_session() then
  vim.keymap.set("n", "gy", '"+yy', { desc = "Yank line to laptop clipboard" })
  vim.keymap.set("n", "gyy", '"+yy', { desc = "Yank line to laptop clipboard" })
  vim.keymap.set("v", "gy", '"+y', { desc = "Yank selection to laptop clipboard" })
end
