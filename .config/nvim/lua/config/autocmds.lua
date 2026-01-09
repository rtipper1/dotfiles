-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Close empty buffers and snacks explorer when opening with nvim .
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- If we opened with a directory (nvim .), close unwanted buffers
    if vim.fn.isdirectory(vim.fn.expand("%")) == 1 or vim.fn.argv(0) == "" then
      -- Wait a bit for buffers to be created
      vim.defer_fn(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local buf_name = vim.api.nvim_buf_get_name(buf)
          local buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf })
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
          -- Close snacks explorer buffers
          if filetype == "snacks" or buf_name:match("snacks") then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
          -- Close empty buffers that aren't neo-tree
          if buf_name == "" and buf_type == "" and vim.api.nvim_buf_line_count(buf) == 1 then
            local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
            if line == "" then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end
        end
      end, 200)
    end
  end,
})
