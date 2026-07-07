-- LSP setup for Neovim 0.12's native vim.lsp API.
-- Server binaries are installed via Nix (see notes below), NOT mason, because
-- mason ships generic-linux prebuilt binaries that can't run on NixOS.
-- nvim-lspconfig ships the server definitions (lsp/*.lua) on the runtimepath.

-- Merge blink's completion capabilities into every server config.
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Enable the servers you have installed on PATH via Nix.
-- Add more here as you install them (names match nvim-lspconfig configs).
vim.lsp.enable({
	"lua_ls",
	"gopls",
	"nixd",
})

vim.lsp.config("nixd", {
	settings = {
		nixd = {
			nixpkgs = {
				-- Used for `pkgs.*` completion.
				expr = "import <nixpkgs> { }",
			},
			options = {
				-- Enables completion/hover for NixOS module options.
				nixos = {
					expr = "(import <nixpkgs/nixos> { }).options",
				},
			},
			formatting = {
				command = { "nixfmt" }, -- matches nixfmt-rfc-style; use { "alejandra" } if you chose that
			},
		},
	},
})

-- Diagnostic display: gutter signs, inline virtual text, and rounded floats.
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true, -- 0.11+ API: boolean/"if_many" ("always" is deprecated)
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

-- Give all LSP hover/signature floating windows a rounded border by default.
do
	local original = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return original(contents, syntax, opts, ...)
	end
end

-- Buffer-local keymaps once a server attaches.
local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local function nmap(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
	end

	nmap("<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump1 = true })
	end, "Go to Definition")

	nmap("<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, "Definition in Vertical Split")

	nmap("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")

	nmap("K", vim.lsp.buf.hover, "Hover Documentation")

	nmap("<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, "Find References")

	nmap("<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, "Find Type Definitions")

	nmap("<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, "Find Document Symbols")

	nmap("<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, "Find Implementations")

	if client:supports_method("textDocument/codeAction", bufnr) then
		nmap("<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, "Organize Imports")
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = lsp_on_attach,
})

-- Global (not buffer-local) diagnostic keymaps. Diagnostics work without an LSP,
-- so these live here rather than in LspAttach.
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<leader>dn", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>dp", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "<leader>dq", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostic List" })
