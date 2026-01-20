local M = {}

function M.open(opts)
	opts = opts or {}

	local unused = require("unused")
	local all_keymaps = unused.get_all()

	-- Convert to list and sort by count ascending
	local items = {}
	for _, meta in pairs(all_keymaps) do
		local is_lazy = meta.source_file and meta.source_file:match("^lazy:")

		table.insert(items, {
			text = string.format("%s  %-15s %4d  %s", meta.mode, meta.lhs, meta.count, meta.desc or ""),
			count = meta.count, -- needed for filter/sort
			file = not is_lazy and meta.source_file or nil,
			line = not is_lazy and meta.source_line or nil,
			lazy_plugin = is_lazy and meta.source_file:gsub("^lazy:", "") or nil,
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

	local display_items = {}
	for _, item in ipairs(items) do
		table.insert(display_items, item.text)
	end

	local prompt = (opts.filter == "unused" and "Unused Keymaps" or "All Keymaps") .. " (" .. #items .. ")"

	vim.ui.select(display_items, {
		prompt = prompt,
	}, function(_, idx)
		if not idx then
			return
		end

		local item = items[idx]
		if not item then
			return
		end

		if item.lazy_plugin then
			vim.notify("[unused.nvim] Key from plugin: " .. item.lazy_plugin, vim.log.levels.INFO)
		elseif item.file and item.line then
			vim.cmd("edit " .. vim.fn.fnameescape(item.file))
			vim.api.nvim_win_set_cursor(0, { item.line, 0 })
		end
	end)
end

return M
