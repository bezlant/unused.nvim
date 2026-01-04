if vim.g.loaded_unused then
  return
end
vim.g.loaded_unused = true

-- Check Neovim version (need 0.10+ for vim.on_key typed argument)
if vim.fn.has("nvim-0.10") == 0 then
  vim.notify("[unused.nvim] Requires Neovim 0.10+", vim.log.levels.ERROR)
  return
end

-- Install hook early, before other plugins define keymaps
require("unused")._hook.install()
