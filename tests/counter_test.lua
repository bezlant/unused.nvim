-- Test: Counter module
-- Run with: nvim --headless -u NONE --cmd "set rtp^=." -c "luafile tests/counter_test.lua" -c "qa!"

package.loaded["unused.counter"] = nil
package.loaded["unused.hook"] = nil

local counter = require("unused.counter")
local hook = require("unused.hook")

-- Test 1: start() registers vim.on_key callback
counter.start(hook.get_registry())
print("PASS: start() runs without error")

-- Test 2: get_counts() returns table
local counts = counter.get_counts()
assert(type(counts) == "table", "get_counts() should return table")
print("PASS: get_counts() returns table")

-- Test 3: increment() updates count
counter.increment("n:<Space>ff")
counter.increment("n:<Space>ff")
counts = counter.get_counts()
assert(counts["n:<Space>ff"] == 2, "increment should update count")
print("PASS: increment() updates count")

-- Test 4: reset_all() clears counts
counter.reset_all()
counts = counter.get_counts()
assert(next(counts) == nil, "reset_all should clear counts")
print("PASS: reset_all() clears counts")

-- Test 5: stop() removes callback
counter.stop()
print("PASS: stop() runs without error")

print("\nAll counter tests passed!")
