vim.o.number = true
vim.o.wrap = false

vim.o.scrolloff = 10
vim.o.sidescrolloff = 10

vim.opt.swapfile = false

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.autoindent = true

vim.opt.foldenable = false

-- Transparency is applied in lua/plugins/colorscheme.lua via a ColorScheme
-- autocmd, so it survives the colorscheme reset (setting one here would be
-- clobbered when the scheme loads).

