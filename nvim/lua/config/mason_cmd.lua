-- mason_cmd.lua — :MasonInstallAll available immediately (not only after opening a file).

local MASON_PLUGINS = {
  "mason.nvim",
  "mason-lspconfig.nvim",
  "mason-tool-installer.nvim",
  "nvim-lspconfig",
}

local EXTRA_TOOLS = {
  "stylua",
  "prettier",
  "clang-format",
  "shfmt",
  "black",
}

local function mason_install_all()
  require("lazy").load({ plugins = MASON_PLUGINS })

  -- Let lazy finish plugin config (registers mason-tool-installer, mason-lspconfig).
  vim.schedule(function()
    if vim.fn.exists(":MasonToolsInstall") == 2 then
      vim.cmd("MasonToolsInstall")
    end

    local ok, registry = pcall(require, "mason-registry")
    if ok then
      for _, name in ipairs(EXTRA_TOOLS) do
        local pkg_ok, pkg = pcall(registry.get_package, name)
        if pkg_ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end

    vim.notify("MasonInstallAll: requested LSP servers + tools (see :Mason)", vim.log.levels.INFO)
  end)
end

vim.api.nvim_create_user_command("MasonInstallAll", mason_install_all, {
  desc = "Install all configured LSP servers and Mason tools",
})
