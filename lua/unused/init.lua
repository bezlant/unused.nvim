local M = {}

local hook = require("unused.hook")
local counter = require("unused.counter")
local storage = require("unused.storage")

local initialized = false

function M.setup(opts)
  opts = opts or {}

  if initialized then
    return
  end

  -- Load existing counts from disk
  local existing_counts = storage.load()
  counter.set_counts(existing_counts)

  -- Start counting
  counter.start(hook.get_registry())

  -- Save on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("unused_nvim", { clear = true }),
    callback = function()
      storage.save(counter.get_counts())
    end,
  })

  initialized = true
end

function M.get_unused()
  local registry = hook.get_registry()
  local counts = counter.get_counts()
  local unused = {}

  for key, meta in pairs(registry) do
    if not counts[key] or counts[key] == 0 then
      unused[key] = meta
    end
  end

  return unused
end

function M.get_all()
  local registry = hook.get_registry()
  local counts = counter.get_counts()
  local all = {}

  for key, meta in pairs(registry) do
    all[key] = vim.tbl_extend("force", meta, {
      count = counts[key] or 0,
    })
  end

  return all
end

function M.reset_all()
  counter.reset_all()
  storage.save({})
end

-- Expose for plugin/unused.lua
M._hook = hook

return M
