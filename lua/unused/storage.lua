local M = {}

local function get_path()
	if vim.g._unused_test_path then
		return vim.g._unused_test_path
	end
	return vim.fn.stdpath("data") .. "/unused.json"
end

function M.load()
	local path = get_path()
	local file = io.open(path, "r")
	if not file then
		return {}
	end
	local content = file:read("*a")
	file:close()
	if content == "" then
		return {}
	end
	local ok, data = pcall(vim.json.decode, content)
	if not ok then
		return {}
	end
	return data
end

function M.save(data)
	local path = get_path()
	local file = io.open(path, "w")
	if not file then
		vim.notify("[unused.nvim] Failed to write " .. path, vim.log.levels.ERROR)
		return false
	end
	file:write(vim.json.encode(data))
	file:close()
	return true
end

function M.merge(existing, new_counts)
	local result = vim.deepcopy(existing)
	for key, count in pairs(new_counts) do
		result[key] = (result[key] or 0) + count
	end
	return result
end

return M
