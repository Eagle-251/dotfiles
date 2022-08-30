-- require'lspconfig'.ansiblels.setup{}
--
-- require'lspconfig'.terraformls.setup{
-- }


local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = {
  "html",
  "bashls",
  "cssls",
  "clangd",
  "ansiblels",
  -- "shellcheck",
  "gopls",
  -- "terraformls",
  -- "terrafor-lsp",
  -- "shfmt",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
