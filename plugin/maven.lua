local api = vim.api
local maven = require("maven")

api.nvim_create_user_command("Maven", function()
  maven.commands()
end, {})
