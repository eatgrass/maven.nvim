local M = {}

-- Function to open the Maven Central website
function M.open_maven_central(get_open_command)
  ---@diagnostic disable-next-line: undefined-field
  local os_name = vim.loop.os_uname().sysname
  local cmd, err = get_open_command(os_name)

  if not cmd then
    vim.notify(err or "Unknown error", vim.log.levels.ERROR)
    return
  end

  -- Execute the command in non-blocking mode
  ---@diagnostic disable-next-line: undefined-field
  vim.loop.spawn(cmd[1], { args = { cmd[2], cmd[3], cmd[4] } }, function(code, _)
    if code ~= 0 then
      vim.notify("Failed to open URL", vim.log.levels.ERROR)
    end
  end)
end

return M
