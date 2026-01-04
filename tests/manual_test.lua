-- Manual test for unused.nvim
-- Run: nvim -u tests/manual_test.lua

-- Minimal config
vim.opt.rtp:prepend(".")

-- Setup unused
require("unused").setup({})

-- Create some test keymaps (these simulate user config keymaps)
-- Note: In real usage, these would be in the user's config
vim.keymap.set("n", "<leader>tt", function()
	print("Test keymap executed!")
end, { desc = "Test keymap" })

vim.keymap.set("n", "<leader>tu", function()
	print("Unused keymap executed!")
end, { desc = "Unused keymap" })

print([[
Manual Test Instructions:
1. Press <leader>tt a few times
2. Run :Unused to see all keymaps
3. Run :Unused unused to see only unused ones
4. Press <CR> on a keymap to jump to definition
5. Run :Unused reset to reset counts
6. Quit and restart to verify persistence
]])
