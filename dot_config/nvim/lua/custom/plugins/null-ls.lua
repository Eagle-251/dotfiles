local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {

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

null_ls.setup {
  debug = true,
  sources = sources,
  -- notify_format = 
}
