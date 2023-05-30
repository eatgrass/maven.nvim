local maven = {}
local View = require("maven.view")
local commands = require("maven.commands")
local config = require("maven.config")

local view

local function has_build_file(cwd)
  return vim.fn.findfile("pom.xml", cwd) ~= ""
end

local function get_cwd()
  local cwd = config.options.cwd or vim.fn.getcwd()
  return cwd
end

function maven.setup(options)
  config.setup(options)
end

function maven.commands()
  local prompt = "Execute maven goal (" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ")"
  vim.ui.select(commands, {
    prompt = prompt,
    format_item = function(item)
      return item.desc or item.cmd
    end,
  }, function(cmd)
    if cmd ~= nil then
      local cwd = get_cwd()
      if not has_build_file(cwd) then
        vim.notify("no pom.xml file found under " .. cwd, vim.log.levels.ERROR)
        return
      end
      maven.execute_command(cmd, cwd)
    end
  end)
end

function maven.execute_command(command, cwd)
  local args = { command.cmd }

  if config.options.settings ~= nil and config.options.settings ~= "" then
    table.insert(args, "-s " .. config.options.settings)
  end

  if command.args ~= nil then
    for _, arg in command.args do
      table.insert(args, arg)
    end
  end

  view = View.create()

  require("plenary.job")
    :new({
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
    :start()
end

return maven
