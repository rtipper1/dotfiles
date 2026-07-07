-- nvim-tree file explorer. Disable netrw first (recommended by nvim-tree) so
-- it doesn't fight over directory buffers.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
	view = {
		width = 35,
	},
	filters = {
		dotfiles = false,
	},
	renderer = {
		group_empty = true,
	},
})

vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle File Explorer" })

-- Keep the tree transparent to match the editor. Colorschemes reset highlights,
-- so reapply on ColorScheme (same pattern as lua/plugins/colorscheme.lua).
local function transparent_tree()
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
end

transparent_tree()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = transparent_tree,
})
