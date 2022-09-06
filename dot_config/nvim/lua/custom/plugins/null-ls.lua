local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {

  -- Languages
  b.formatting.gofmt,

  -- IaC
  b.diagnostics.ansiblelint,
  b.formatting.terraform_fmt,
  -- webdev stuff
  b.formatting.deno_fmt,
  b.formatting.prettier,

  -- Lua
  b.formatting.stylua,

  -- Shell
  b.formatting.shfmt,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
}

-- local notify = require()

local nullSaveOnClose = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = nullSaveOnClose, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = nullSaveOnClose,
        buffer = bufnr,
        callback = function()
          -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
          vim.lsp.buf.formatting_sync()
        end,
      })
    end
  end,
  -- notify_format =
}
