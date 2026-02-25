local wk = require("which-key")

wk.setup({
	preset = "helix",
	spec = {
		{
			mode = { "n", "x" },
			{ "<leader><tab>", group = "Tabs" },
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>dp", group = "Profiler" },
			{ "<leader>f", group = "File/Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>gh", group = "Hunks" },
			{ "<leader>h", group = "Hunks" },
			{ "<leader>n", group = "Next" },
			{ "<leader>o", group = "Organize" },
			{ "<leader>p", group = "Previous/Path" },
			{ "<leader>q", group = "Quit/Session" },
			{ "<leader>r", group = "Rename/Refactor" },
			{ "<leader>s", group = "Search" },
			{ "<leader>t", group = "Toggle" },
			{ "<leader>u", group = "UI" },
			{ "<leader>x", group = "Diagnostics/Quickfix" },
			{ "[", group = "Previous" },
			{ "]", group = "Next" },
			{ "g", group = "Go To" },
			{ "gs", group = "Surround" },
			{ "z", group = "Fold" },
			{
				"<leader>b",
				group = "Buffer",
				expand = function()
					return require("which-key.extras").expand.buf()
				end,
			},
			{
				"<leader>w",
				group = "Windows",
				proxy = "<c-w>",
				expand = function()
					return require("which-key.extras").expand.win()
				end,
			},
			{ "gx", desc = "Open with System App" },
		},
	},
})

local function style_which_key_groups()
	-- Keep group labels the same color as regular entries while preserving the "+" prefix.
	vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "WhichKey" })
end

style_which_key_groups()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = style_which_key_groups,
})

vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer Keymaps" })

vim.keymap.set("n", "<c-w><space>", function()
	require("which-key").show({ keys = "<c-w>", loop = true })
end, { desc = "Window Hydra Mode" })

