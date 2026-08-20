-- nvim-treesitter `main` branch API (Neovim 0.12+).
-- Requires tree-sitter-cli on PATH to compile parsers (Arch: tree-sitter-cli).
local ts = require("nvim-treesitter")

-- Parsers to keep installed/updated. Add languages you use here.
ts.install({
	"lua",
	"vim",
	"vimdoc",
	"query",
	"bash",
	"markdown",
	"markdown_inline",
	"go",
	"python",
})

local function enable_treesitter(bufnr)
	if pcall(vim.treesitter.start, bufnr) then
		vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

-- Enable treesitter highlighting for buffers whose filetype has a parser.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		enable_treesitter(args.buf)
	end,
})

-- Parsers install asynchronously on startup; re-apply highlighting to open
-- buffers once installation finishes.
vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype ~= "" then
				enable_treesitter(bufnr)
			end
		end
	end,
})
