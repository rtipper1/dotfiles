-- nvim-treesitter `main` branch API (Neovim 0.12+).
-- Parsers install asynchronously; highlighting is turned on per-buffer via
-- vim.treesitter.start() so it also applies once a parser finishes installing.
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

-- Enable treesitter highlighting (and its indent expr) for any buffer whose
-- filetype has a parser available. pcall guards filetypes without a parser.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
