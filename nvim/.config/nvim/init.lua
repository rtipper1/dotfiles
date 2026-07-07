-- Entry point. The `lua/` directory is the module root, so `require("x")`
-- loads `lua/x.lua` (or `lua/x/init.lua`). Do NOT prefix requires with "lua.".

-- Core settings first so the leader key is set before plugins register mappings.
require("options")
require("keymaps")

-- Install and configure plugins (see lua/plugins/init.lua).
require("plugins")
