-- which-key: shows a popup of available keybindings after you press a prefix
-- (e.g. <leader>) and pause. Any keymap with a `desc` is listed automatically.
local wk = require("which-key")

wk.setup({
	-- "helix" preset renders the popup as a vertical menu in the bottom-right corner.
	preset = "helix",
	spec = {
		{
			mode = { "n", "x" },
			-- Group labels for prefixes that actually have keymaps, named for
			-- what the maps under them do.
			{ "<leader>d", group = "Diagnostics" }, -- dd float, dn/dp next/prev, dq list, dt toggle
			{ "<leader>f", group = "Find" }, -- <leader>ff/fr/ft/fs/fi (fzf-lua)
			{ "<leader>g", group = "Goto" }, -- <leader>gd/gS goto definition
			{ "<leader>o", group = "Organize" }, -- <leader>oi organize imports
			{ "<leader>r", group = "Rename" }, -- <leader>rn rename symbol
			{ "<leader>s", group = "Split" }, -- <leader>sv/sh split windows
			{ "gr", group = "LSP" }, -- grn/gra/grr (Neovim default LSP maps)
		},
	},
})

-- Keep group labels the same color as regular entries while preserving the "+" prefix.
local function style_which_key_groups()
	vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "WhichKey" })
end

style_which_key_groups()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = style_which_key_groups,
})

-- Show only the buffer-local keymaps (handy for LSP maps in a code buffer).
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer Keymaps" })

-- Hydra mode for window commands: keeps the <C-w> menu open for repeated presses.
vim.keymap.set("n", "<c-w><space>", function()
	require("which-key").show({ keys = "<c-w>", loop = true })
end, { desc = "Window Hydra Mode" })
