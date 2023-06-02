local api = vim.api
local maven = require("maven")

api.nvim_create_user_command("Maven", function()
  maven.commands()
end, {})

api.nvim_create_user_command("MavenExec", function()
  vim.ui.input({ prompt = "Execute goal: " }, function(input)
    local command = maven.to_command(input)
    maven.execute_command(command)
  end)
end, {})

vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  callback = maven.kill_running_job,
})
