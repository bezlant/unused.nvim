local M = {}

local original_keymap_set = nil
local registry = {}

local function get_config_path()
	return vim.fn.stdpath("config")
end

local function is_user_config(source_file)
	local config_path = get_config_path()
	return source_file:find(config_path, 1, true) ~= nil
end

local function normalize_lhs(lhs)
	local termcodes = vim.api.nvim_replace_termcodes(lhs, true, true, true)
	return vim.fn.keytrans(termcodes)
end

function M.install()
	if original_keymap_set then
		return -- Already installed
	end

	original_keymap_set = vim.keymap.set

	---@diagnostic disable-next-line: duplicate-set-field
	vim.keymap.set = function(mode, lhs, rhs, opts)
		-- Capture source location
		local info = debug.getinfo(2, "Sl")
		local source_file = info.source
		if source_file:sub(1, 1) == "@" then
			source_file = source_file:sub(2)
		end

		-- Only track user config keymaps
		if is_user_config(source_file) then
			local normalized_lhs = normalize_lhs(lhs)
			local modes = type(mode) == "table" and mode or { mode }

			for _, m in ipairs(modes) do
				local key = m .. ":" .. normalized_lhs
				registry[key] = {
					lhs = lhs,
					normalized_lhs = normalized_lhs,
					mode = m,
					desc = opts and opts.desc or "",
					source_file = source_file,
					source_line = info.currentline,
				}
			end
		end

		-- Call original
		return original_keymap_set(mode, lhs, rhs, opts)
	end
end

function M.uninstall()
	if original_keymap_set then
		vim.keymap.set = original_keymap_set
		original_keymap_set = nil
	end
end

function M.get_registry()
	return registry
end

function M.clear_registry()
	registry = {}
end

function M.scan_lazy_keys()
	local ok, lazy_config = pcall(require, "lazy.core.config")
	if not ok then
		return 0
	end

	local count = 0
	for plugin_name, plugin in pairs(lazy_config.plugins) do
		if plugin.keys and type(plugin.keys) == "table" then
			for _, keyspec in ipairs(plugin.keys) do
				local lhs = keyspec[1]
				if lhs then
					local normalized_lhs = normalize_lhs(lhs)
					local mode_spec = keyspec.mode or "n"
					local modes = type(mode_spec) == "table" and mode_spec or { mode_spec }

					for _, m in ipairs(modes) do
						local key = m .. ":" .. normalized_lhs
						-- Don't overwrite if already registered by hook
						if not registry[key] then
							registry[key] = {
								lhs = lhs,
								normalized_lhs = normalized_lhs,
								mode = m,
								desc = keyspec.desc or "",
								source_file = "lazy:" .. plugin_name,
								source_line = nil,
							}
							count = count + 1
						end
					end
				end
			end
		end
	end

	return count
end

return M
