-- lua/plugins/snacks.lua

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
        },
      },
    },
    -- Disable explorer component entirely - we use neo-tree instead
    explorer = {
      enabled = false,
    },
  },
}
