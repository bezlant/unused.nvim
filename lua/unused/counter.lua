local M = {}

local counts = {}
local registry_ref = nil
local callback_id = nil

function M.start(registry)
	registry_ref = registry

	callback_id = vim.on_key(function(mapped, typed)
		if not typed or typed == "" then
			return
		end

		local mode = vim.api.nvim_get_mode().mode
		local normalized = vim.fn.keytrans(typed)
		local key = mode .. ":" .. normalized

		if registry_ref and registry_ref[key] then
			counts[key] = (counts[key] or 0) + 1
		end
	end)
end

function M.stop()
	if callback_id then
		vim.on_key(nil, callback_id)
		callback_id = nil
	end
end

function M.get_counts()
	return counts
end

function M.set_counts(new_counts)
	counts = new_counts or {}
end

function M.increment(key)
	counts[key] = (counts[key] or 0) + 1
end

function M.reset_all()
	counts = {}
end

return M
