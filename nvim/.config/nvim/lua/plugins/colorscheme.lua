-- Everforest colorscheme.
--
-- Applying a colorscheme resets every highlight group, so our overrides can't be
-- one-off nvim_set_hl calls (they'd be clobbered by :colorscheme). Instead we
-- reapply them on the ColorScheme event, which fires every time a scheme loads.

vim.g.everforest_background = "soft" -- "soft" | "medium" | "hard"
-- Clear editor backgrounds so Ghostty's opacity shows through. Regular Ghostty
-- windows are opaque (solid look); only the floating terminal uses
-- --background-opacity, so transparency only appears there.
-- Note: this links NormalFloat -> Normal (transparent), which we override below.
vim.g.everforest_transparent_background = 2

-- Everforest "medium" palette bits used for solid popup backgrounds.
local palette = {
	fg = "#d3c6aa",
	grey = "#859289",
	float_bg = "#343f44", -- bg1: a touch lighter than the editor for contrast
}

local function apply_highlights()
	-- Transparent editor chrome: opaque Ghostty -> solid; floating Ghostty -> see-through.
	for _, group in ipairs({ "Normal", "EndOfBuffer", "SignColumn" }) do
		vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
	end
	-- Solid popup backgrounds for readability (LSP hover, diagnostics, which-key).
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = palette.fg, bg = palette.float_bg })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = palette.grey, bg = palette.float_bg })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = apply_highlights,
})

vim.cmd.colorscheme("everforest")
