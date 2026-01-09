return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        -- Don't open empty buffers when opening directories
        hijack_netrw_behavior = "open_current",
        follow_current_file = {
          enabled = true,
        },
      },
      -- Close neo-tree if it's the last window
      close_if_last_window = true,
      -- Don't open automatically on startup when opening a directory
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
    },
  },
}

