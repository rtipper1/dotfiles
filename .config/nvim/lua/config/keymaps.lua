-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove default leader E and e keymaps
vim.keymap.del("n", "<leader>e")
vim.keymap.del("n", "<leader>E")

-- Set leader e to open file explorer in current working directory
vim.keymap.set("n", "<leader>e", function()
  vim.cmd("Neotree toggle left dir=" .. vim.fn.getcwd())
end, { desc = "Toggle Explorer (cwd)" })

