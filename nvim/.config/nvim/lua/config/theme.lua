local M = {}

local uv = vim.uv or vim.loop
local theme_name_file = vim.fn.expand("~/.config/omarchy/current/theme.name")
local theme_neovim_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
local fallback_theme = "gruvbox"

local active_theme = nil
local warned_theme = nil
local watcher = nil
local attempted_plugin_installs = {}
local repo_to_pack_name = {
	["catppuccin/nvim"] = "catppuccin",
	["rose-pine/neovim"] = "rose-pine",
}

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()
	return content
end

local function trim(value)
	if not value then
		return nil
	end

	local result = value:gsub("^%s+", ""):gsub("%s+$", "")
	if result == "" then
		return nil
	end

	return result
end

local function read_theme_name()
	return trim(read_file(theme_name_file))
end

local function normalize_repo(repo)
	if not repo then
		return nil
	end

	local owner, name = repo:match("^https?://github.com/([^/]+)/([^/]+)$")
	if owner and name then
		return owner .. "/" .. name
	end

	owner, name = repo:match("^([^/]+)/([^/]+)$")
	if owner and name then
		return owner .. "/" .. name
	end

	return nil
end

local function get_pack_name_for_repo(repo)
	local normalized = normalize_repo(repo)
	if not normalized then
		return nil
	end

	if repo_to_pack_name[normalized] then
		return repo_to_pack_name[normalized]
	end

	return normalized:match("/([^/]+)$")
end

local function read_omarchy_neovim_settings()
	local content = read_file(theme_neovim_file)
	if not content then
		return nil, nil, nil
	end

	local colorscheme = trim(content:match('colorscheme%s*=%s*"(.-)"'))
		or trim(content:match('colorscheme%("(.+)"%)'))
	local repo = nil

	for plugin in content:gmatch('%{%s*"(.-)"') do
		if plugin ~= "LazyVim/LazyVim" and not plugin:match("^%s*LazyVim/") then
			repo = plugin
			break
		end
	end

	return colorscheme, get_pack_name_for_repo(repo), repo
end

local function repo_to_src(repo)
	local normalized = normalize_repo(repo)
	if not normalized then
		return nil
	end

	return "https://github.com/" .. normalized
end

local function load_theme_plugin(pack_name, repo)
	if pack_name then
		local ok = pcall(vim.cmd, "packadd " .. pack_name)
		if ok then
			return
		end
	end

	local src = repo_to_src(repo)
	if not src then
		return
	end

	local install_key = pack_name or src
	if attempted_plugin_installs[install_key] then
		return
	end
	attempted_plugin_installs[install_key] = true

	pcall(vim.pack.add, {
		{
			src = src,
			name = pack_name,
		},
	})

	if pack_name then
		pcall(vim.cmd, "packadd " .. pack_name)
	end
end

local function apply_theme(theme)
	if not theme or theme == active_theme then
		return
	end

	local ok = pcall(vim.cmd.colorscheme, theme)
	if ok then
		active_theme = theme
		warned_theme = nil
		return
	end

	if warned_theme ~= theme then
		vim.notify("Omarchy theme '" .. theme .. "' is not installed in Neovim", vim.log.levels.WARN)
		warned_theme = theme
	end
end

function M.sync()
	local colorscheme, pack_name, repo = read_omarchy_neovim_settings()
	load_theme_plugin(pack_name, repo)

	local theme = colorscheme or read_theme_name() or fallback_theme
	apply_theme(theme)
end

function M.setup()
	M.sync()

	local group = vim.api.nvim_create_augroup("OmarchyThemeSync", { clear = true })
	vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
		group = group,
		callback = function()
			M.sync()
		end,
	})

	if uv and uv.new_fs_event then
		watcher = uv.new_fs_event()
		if watcher then
			watcher:start(theme_name_file, {}, vim.schedule_wrap(function()
				M.sync()
			end))

			vim.api.nvim_create_autocmd("VimLeavePre", {
				group = group,
				once = true,
				callback = function()
					if watcher then
						watcher:stop()
						watcher:close()
						watcher = nil
					end
				end,
			})
		end
	end
end

return M

