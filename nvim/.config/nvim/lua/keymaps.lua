-- Set leader keys before plugins load (mappings capture the leader at define time).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General, plugin-independent keymaps go here.
-- Plugin-specific keymaps live alongside their plugin config in lua/plugins/.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlights" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus Lower Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus Upper Window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus Right Window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split Window Vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split Window Horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase Window Width" })

vim.keymap.set("n", "<leader>dt", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })
