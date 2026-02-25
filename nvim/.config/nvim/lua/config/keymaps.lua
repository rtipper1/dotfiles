vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear Search Highlights" })

vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste Without Yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete Without Yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous Buffer" })

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

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move Line Down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move Line Up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent Left and Reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right and Reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join Lines and Keep Cursor Position" })

vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy Full File Path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })

