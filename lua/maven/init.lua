local maven = {}
local View = require("maven.view")
local commands = require("maven.commands")
local config = require("maven.config")
local validate = require("maven.validate")
local actions = require("maven.actions")
local uv = vim.loop

local view
local job

local function get_cwd()
  local cwd = config.options.cwd or vim.fn.getcwd()
  return cwd
end

function maven.setup(options)
  config.setup(options)
  if config.options.commands ~= nil then
    for _, command in pairs(config.options.commands) do
      table.insert(commands, command)
    end
  end
end

function maven.commands()
  local prompt = "Execute maven goal (" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ")"
  local cwd = get_cwd()

  vim.ui.select(commands, {
    prompt = prompt,
    format_item = function(item)
      return item.desc or item.cmd[1]
    end,
  }, function(cmd)
    if not cmd then
      vim.notify("No maven command")
      return
    end

    local params
    if type(cmd.cmd) == "function" then
      cmd.cmd(function(p)
        params = p
        -- Make sure params.cmd is a string table
        local cmd_copy = params.cmd
        if type(cmd_copy) == "string" then
          cmd_copy = vim.split(cmd_copy, " ")
        end
        params.cmd = cmd_copy

        -- Validate before executing the generated command
        local is_valid_params, message_params = validate.validate(params, cwd)
        if not is_valid_params then
          vim.notify(message_params, vim.log.levels.ERROR)
          return
        end

        local cmd_str = table.concat(params.cmd, " ")
        vim.notify("Executing command: " .. cmd_str)
        maven.execute_command(params)
      end)
    else
      -- Validate before executing the generated command
      local is_valid_cmd, message_cmd = validate.validate(cmd, cwd)
      if not is_valid_cmd then
        vim.notify(message_cmd, vim.log.levels.ERROR)
        return
      end
      if cmd.cmd[1] == "add-dependency" then
        return actions.add_dependency_to_pom()
      else
        return maven.execute_command(cmd)
      end
    end
  end)
end
---@return MavenCommandOption|nil
function maven.to_command(str)
  if str == nil or str == "" then
    return
  end
  local cmd = {}
  for command in str:gmatch("%S+") do
    table.insert(cmd, command)
  end
  return { cmd = cmd }
end

function maven.execute_command(command)
  local cwd = get_cwd()

  maven.kill_running_job()

  local args = {}

  if config.options.settings ~= nil and config.options.settings ~= "" then
    table.insert(args, "-s")
    table.insert(args, config.options.settings)
  end

  for _, arg in pairs(command.cmd) do
    table.insert(args, arg)
  end

  view = View.create()

  job = require("plenary.job"):new({
    command = config.options.executable,
    args = args,
    cwd = cwd,
    on_stdout = function(_, data)
      view:render_line(data)
    end,
    on_stderr = function(_, data)
      vim.schedule(function()
        view:render_line(data)
      end)
    end,
  })

  view.job = job

  job:start()
end

function maven.kill_running_job()
  if job and job.pid then
    ---@diagnostic disable-next-line: undefined-field
    uv.kill(job.pid, 15)
    job = nil
  end
end

return maven
