local M = {}

-- Checks if there is a pom.xml file in the directory
local function has_build_file(cwd)
  return vim.fn.findfile("pom.xml", cwd) ~= ""
end

-- Checks whether a tag with specific content is present in pom.xml
local function has_required_tag_in_pom(cwd, tag, content)
  local pom_file = cwd .. "/pom.xml"
  -- Checks if the file exists
  if vim.fn.filereadable(pom_file) == 0 then
    return false
  end
  -- Read the contents of the pom.xml file
  local pom_content = table.concat(vim.fn.readfile(pom_file), "\n")
  -- Checks if the tag with the content is present
  local pattern = "<" .. tag .. ">%s*" .. content:gsub("%s+", "%%s*") .. "%s*</" .. tag .. ">"
  return pom_content:match(pattern) ~= nil
end

-- validation to check conditions before executing the command
function M.validate(cmd, cwd)
  if type(cmd.cmd) ~= "table" or not cmd.cmd[1] then
    return false, "Invalid command structure."
  end

  if cmd.cmd[1] ~= "archetype:generate" and not has_build_file(cwd) then
    return false, "No pom.xml file found under " .. cwd
  end
  if cmd.cmd[1] == "archetype:generate" then
    if has_build_file(cwd) then
      if has_required_tag_in_pom(cwd, "packaging", "pom") then
        return true, "Required tag found in pom.xml. Proceeding with Maven multi-module project creation."
      else
        return false,
          "There is a pom.xml file indicating that there is already a Maven project in the directory: " .. cwd
      end
    else
      return true, "No existing pom.xml found. Proceeding to create a new Maven project."
    end
  end

  return true, "Command is valid and can be executed."
end

return M
