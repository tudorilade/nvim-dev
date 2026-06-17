-- clipboard.lua — route yanks to the right clipboard per environment.
--
-- SSH: Neovim's OSC 52 provider (never raw io.write — that corrupts terminals).
-- WSL: win32yank → Windows clipboard.
-- Local: xclip/xsel/wl-copy when available.

local opt = vim.opt

local function is_ssh_session()
  return (vim.env.SSH_TTY and vim.env.SSH_TTY ~= "")
    or (vim.env.SSH_CONNECTION and vim.env.SSH_CONNECTION ~= "")
    or (vim.env.SSH_CLIENT and vim.env.SSH_CLIENT ~= "")
end

local function use_osc52()
  return (is_ssh_session() or vim.env.NVIM_DEV_LAPTOP_CLIPBOARD == "1")
    and vim.env.NVIM_NO_OSC52 ~= "1"
end

-- WSL → Windows clipboard (local, not SSH).
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
elseif use_osc52() then
  -- SSH: laptop clipboard via OSC 52. Does NOT use remote xclip.
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy,
      ["*"] = osc52.copy,
    },
    paste = {
      ["+"] = osc52.paste,
      ["*"] = osc52.paste,
    },
  }
  opt.clipboard = "unnamedplus"

  -- Explicit "+y when unnamedplus behaviour is unclear in a plugin/terminal.
  vim.keymap.set({ "n", "v" }, "gy", '"+y', { desc = "Yank to laptop clipboard" })
  vim.keymap.set("n", "gY", '"+Y', { desc = "Yank line to laptop clipboard" })

  vim.schedule(function()
    vim.notify("SSH clipboard: y/yy → laptop (OSC 52)", vim.log.levels.INFO)
  end)
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
