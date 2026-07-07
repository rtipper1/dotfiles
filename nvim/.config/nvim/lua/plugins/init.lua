-- Plugin management with Neovim's built-in manager (vim.pack, 0.12+).
vim.pack.add({
	"https://github.com/sainnhe/everforest",
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/ibhagwan/fzf-lua",
	-- Treesitter's rewrite lives on the `main` branch (recommended on 0.12+).
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	-- LSP: server definitions consumed by vim.lsp.enable(). On NixOS the server
	-- binaries themselves are installed via Nix, not mason.
	"https://github.com/neovim/nvim-lspconfig",
	-- Completion: pin to a 1.x release tag so blink pulls its prebuilt binary.
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },	
	"https://github.com/nvim-lualine/lualine.nvim",
	-- Statusline extras: file icons + git signs/diff data for lualine.
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/lewis6991/gitsigns.nvim",
	-- Popup that shows available keybindings as you type a prefix.
	"https://github.com/folke/which-key.nvim",
	-- Collection of small modules; we use mini.cursorword (see plugins/mini.lua).
	"https://github.com/echasnovski/mini.nvim",
})

-- Per-plugin setup. Each module lives in lua/plugins/<name>.lua.
-- Load the colorscheme first so later modules can override its highlights.
require("plugins.colorscheme")
require("plugins.nvimtree")
require("plugins.fzf")
require("plugins.treesitter")
require("plugins.blink")
require("plugins.lsp")
-- gitsigns before lualine so its diff data is available to the statusline.
require("plugins.gitsigns")
require("plugins.lualine")
require("plugins.which-key")
require("plugins.mini")
