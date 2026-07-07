-- blink.cmp: completion. Minimal setup using the default keymap preset.
-- <C-space> open/docs, <C-y> accept, <Tab>/<S-Tab> to cycle in menu.
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	-- On a release tag blink downloads a prebuilt Rust binary automatically.
	fuzzy = { implementation = "prefer_rust_with_warning" },
})
