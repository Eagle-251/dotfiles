-- example file i.e lua/custom/init.lua
-- load your options globals, autocmds here or anything .__.
-- you can even override default options here (core/options.lua)
-- vim.notify = require "notify"

vim.g.suda_smart_edit = 1

local numberToggleAugroup = vim.api.nvim_create_augroup("numbertoggle", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  pattern = "*",
  group = numberToggleAugroup,
  desc = "Turn on relative numbers on entering insert mode",
  command = 'if &nu && mode() != "i" | set rnu   | endif',
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  pattern = "*",
  group = numberToggleAugroup,
  desc = "Turn off relative numbers on entering insert mode",
  command = "if &nu | set nornu | endif",
})
