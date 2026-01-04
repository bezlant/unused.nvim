-- Test: Storage module
-- Run with: nvim --headless -u NONE -c "luafile tests/storage_test.lua" -c "qa!"

-- Mock vim.fn.stdpath for testing
local test_file = "/tmp/unused_test.json"
package.loaded["unused.storage"] = nil

-- Inject test path
vim.g._unused_test_path = test_file

-- Clean up before test
os.remove(test_file)

local storage = require("unused.storage")

-- Test 1: Load returns empty table when file doesn't exist
local data = storage.load()
assert(type(data) == "table", "load() should return table")
assert(next(data) == nil, "load() should return empty table when file missing")
print("PASS: load() returns empty table when file missing")

-- Test 2: Save and load roundtrip
local test_data = {
	["n:<Space>ff"] = 5,
	["n:<Space>fg"] = 0,
}
storage.save(test_data)
local loaded = storage.load()
assert(loaded["n:<Space>ff"] == 5, "roundtrip failed for n:<Space>ff")
assert(loaded["n:<Space>fg"] == 0, "roundtrip failed for n:<Space>fg")
print("PASS: save/load roundtrip works")

-- Test 3: Merge combines counts
local existing = { ["n:<Space>ff"] = 3, ["n:<Space>xx"] = 10 }
local new_counts = { ["n:<Space>ff"] = 2, ["n:<Space>yy"] = 1 }
local merged = storage.merge(existing, new_counts)
assert(merged["n:<Space>ff"] == 5, "merge should add counts")
assert(merged["n:<Space>xx"] == 10, "merge should keep existing")
assert(merged["n:<Space>yy"] == 1, "merge should add new keys")
print("PASS: merge combines counts correctly")

-- Cleanup
os.remove(test_file)
print("\nAll storage tests passed!")
