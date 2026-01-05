-- Test: Hook module
-- Run with: nvim --headless -u NONE --cmd "set rtp^=." -c "luafile tests/hook_test.lua" -c "qa!"

package.loaded["unused.hook"] = nil
local hook = require("unused.hook")

-- Test 1: install() replaces vim.keymap.set
local original = vim.keymap.set
hook.install()
assert(vim.keymap.set ~= original, "install() should replace vim.keymap.set")
print("PASS: install() replaces vim.keymap.set")

-- Test 2: Keymaps still work after hook
vim.keymap.set("n", "<Plug>(test-mapping)", function() end, { desc = "Test" })
local maps = vim.api.nvim_get_keymap("n")
local found = false
for _, map in ipairs(maps) do
	if map.lhs == "<Plug>(test-mapping)" then
		found = true
		break
	end
end
assert(found, "keymap should still be created")
print("PASS: keymaps still work after hook")

-- Test 3: uninstall() restores original
hook.uninstall()
assert(vim.keymap.set == original, "uninstall() should restore original")
print("PASS: uninstall() restores original")

print("\nAll hook tests passed!")
