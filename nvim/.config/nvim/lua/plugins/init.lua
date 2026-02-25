vim.pack.add(require("plugins.spec"))

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")
packadd("gruvbox.nvim")
packadd("which-key.nvim")
packadd("nvim-web-devicons")
packadd("lualine.nvim")

local ok = pcall(vim.cmd.colorscheme, "gruvbox")
if not ok then
	vim.notify("colorscheme 'gruvbox' not available; using default", vim.log.levels.WARN)
end

require("plugins.treesitter")
require("plugins.nvim-tree")
require("plugins.fzf")
require("plugins.mini")
require("plugins.gitsigns")
require("plugins.lsp")
require("plugins.which-key")
require("plugins.lualine")

