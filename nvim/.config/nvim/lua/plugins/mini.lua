-- mini.nvim modules. Each mini module is set up independently; only those
-- called here are active. Add more mini modules below as you adopt them.

-- Highlights all occurrences of the word under the cursor.
require("mini.cursorword").setup()

-- Force underline (not bold) for the cursorword highlights. Reapply on
-- ColorScheme so a theme switch/reload doesn't revert it.
local function set_cursorword_hl()
	vim.api.nvim_set_hl(0, "MiniCursorword", { underline = true })
	vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { underline = true })
end
set_cursorword_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_cursorword_hl })
