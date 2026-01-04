-- Integration test for unused.nvim
-- Run with: nvim --headless -u NORC --cmd "set rtp^=." --cmd "filetype plugin on" -c "luafile tests/integration_test.lua" -c "q"

-- Clean up test data
vim.g._unused_test_path = "/tmp/unused_integration_test.json"
os.remove("/tmp/unused_integration_test.json")

print("=== Integration Test ===\n")

-- 1. Plugin should be loaded
assert(vim.g.loaded_unused, "Plugin should be loaded")
print("PASS: Plugin loaded")

-- 2. Setup should work
local unused = require("unused")
unused.setup({})
print("PASS: Setup completed")

-- 3. Registry should be accessible
local hook = require("unused.hook")
local registry = hook.get_registry()
assert(type(registry) == "table", "Registry should be a table")
print("PASS: Registry accessible")

-- 4. Counter should be accessible
local counter = require("unused.counter")
local counts = counter.get_counts()
assert(type(counts) == "table", "Counts should be a table")
print("PASS: Counter accessible")

-- 5. get_all should return table
local all = unused.get_all()
assert(type(all) == "table", "get_all should return table")
print("PASS: get_all works")

-- 6. get_unused should return table
local unused_keymaps = unused.get_unused()
assert(type(unused_keymaps) == "table", "get_unused should return table")
print("PASS: get_unused works")

-- 7. reset_all should work
unused.reset_all()
counts = counter.get_counts()
assert(next(counts) == nil, "reset_all should clear counts")
print("PASS: reset_all works")

-- 8. Command should exist
local commands = vim.api.nvim_get_commands({})
assert(commands["Unused"], "Unused command should exist")
print("PASS: :Unused command exists")

-- Cleanup
os.remove("/tmp/unused_integration_test.json")

print("\n=== All integration tests passed! ===")
