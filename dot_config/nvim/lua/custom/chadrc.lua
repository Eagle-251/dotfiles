-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
  theme = "wombat",
}
M.plugins = {
  user = {
    ["neovim/nvim-lspconfig"] = {
      config = function()
        require "plugins.configs.lspconfig"
        require "custom.plugins.lspservers"
      end,
    },
    ["jose-elias-alvarez/null-ls.nvim"] = {
      after = "nvim-lspconfig",
      config = function()
        require "custom.plugins.null-ls"
      end,
    },
    ["rcarriga/nvim-notify"] = {
      after = "null-ls.nvim",
    },
    ["goolord/alpha-nvim"] = {
      disable = false,
    },
  },
  -- ["goolord/alpha-nvim"] = {
  --   disable = false,
  -- },
}

return M
