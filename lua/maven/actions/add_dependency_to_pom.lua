local M = {}

local utils = require("maven.utils")
local config = require("maven.config")

function M.add_dependency_to_pom()
  -- Function that defines the command to open Maven Central according to the OS
  local function get_open_command(os_name)
    local url = config.options.maven_central_url
    if os_name == "Linux" or os_name == "FreeBSD" or os_name == "OpenBSD" or os_name == "NetBSD" then
      return { "xdg-open", url }, nil
    elseif os_name == "Darwin" then
      return { "open", url }, nil
    elseif os_name == "Windows_NT" then
      return { "cmd.exe", "/C", "start", url }, nil
    else
      return nil, "Unsupported OS"
    end
  end

  utils.open_maven_central(get_open_command)

  local buf, win = utils.create_floating_window()

  local function remove_instruction()
    utils.remove_instruction(buf, win)
  end

  -- Function to remove instruction message
  vim.defer_fn(function()
    vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged", "TextChangedP" }, {
      buffer = buf,
      callback = function()
        remove_instruction()
      end,
    })
  end, 500)

  -- Maps <enter> to close the window and capture the content
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    noremap = true,
    callback = function()
      local lines_dependency = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local dependency = table.concat(lines_dependency, "\n")

      if dependency == "" then
        vim.notify("No dependency provided", vim.log.levels.WARN)
        return
      end

      local function get_cwd()
        return require("maven.config").options.cwd or vim.fn.getcwd()
      end

      local pom_file = get_cwd() .. "/pom.xml"

      -- Read the contents of pom.xml
      local pom_content = table.concat(vim.fn.readfile(pom_file), "\n")

      local function normalize_string(str)
        return str:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
      end

      -- Function to check if the dependency is already present
      local function is_dependency_present(p_content, dep)
        local normalized_dependency = normalize_string(dep)
        local normalized_pom_content = normalize_string(p_content)
        return normalized_pom_content:find(normalized_dependency, 1, true) ~= nil
      end

      if is_dependency_present(pom_content, dependency) then
        vim.notify("Dependency already exists in pom.xml", vim.log.levels.INFO)
        return
      end

      local lines = {}
      for line in io.lines(pom_file) do
        table.insert(lines, line)
      end

      local insert_index = nil
      for i, line in ipairs(lines) do
        if line:find("</dependencies>") then
          insert_index = i
          break
        end
      end

      if insert_index then
        local formatted_dependency =
          dependency:gsub("\n%s*<", "\n      <"):gsub("\n%s*</dependency>", "\n    </dependency>")
        table.insert(lines, insert_index, "    " .. formatted_dependency)
      else
        vim.notify("No </dependencies> tag found in pom.xml", vim.log.levels.ERROR)
        return
      end

      local file = io.open(pom_file, "w")
      if not file then
        vim.notify("Failed to open pom.xml for writing", vim.log.levels.ERROR)
        return
      end

      for _, line in ipairs(lines) do
        file:write(line .. "\n")
      end
      file:close()

      vim.notify("Dependency added to pom.xml", vim.log.levels.INFO)
      vim.api.nvim_win_close(win, true)
    end,
  })
end

return M
