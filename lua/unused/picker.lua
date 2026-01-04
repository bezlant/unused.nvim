local M = {}

function M.open(opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("[unused.nvim] snacks.nvim is required for picker", vim.log.levels.ERROR)
    return
  end

  local unused = require("unused")
  local all_keymaps = unused.get_all()

  -- Convert to list and sort by count ascending
  local items = {}
  for key, meta in pairs(all_keymaps) do
    table.insert(items, {
      text = string.format("%-3s %-20s %5d   %s", meta.mode, meta.lhs, meta.count, meta.desc),
      key = key,
      mode = meta.mode,
      lhs = meta.lhs,
      count = meta.count,
      desc = meta.desc or "",
      file = meta.source_file,
      line = meta.source_line,
    })
  end

  -- Filter if requested
  if opts.filter == "unused" then
    items = vim.tbl_filter(function(item)
      return item.count == 0
    end, items)
  end

  -- Sort by count ascending (unused first)
  table.sort(items, function(a, b)
    return a.count < b.count
  end)

  if #items == 0 then
    vim.notify("[unused.nvim] No keymaps tracked yet", vim.log.levels.INFO)
    return
  end

  snacks.picker.pick({
    title = opts.filter == "unused" and "Unused Keymaps" or "All Keymaps",
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item and item.file and item.line then
        vim.cmd("edit " .. vim.fn.fnameescape(item.file))
        vim.api.nvim_win_set_cursor(0, { item.line, 0 })
      end
    end,
  })
end

return M
