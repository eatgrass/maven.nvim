local M = {}

M.namespace = vim.api.nvim_create_namespace("Maven")

---@class MavenOptions
---@field executable string
---@field cwd string|nil
---@field settings string|nil
---@field commands MavenCommandOption[]|nil
local defaults = {
  executable = "./mvnw", -- `mvn` should be in your `PATH`, or the absolute path or the maven exectable, or `./mvnw`
  cwd = nil, -- work directory, default to `vim.fn.getcwd()`
  settings = nil, -- specify the settings file or use the default settings
  commands = nil, -- add custom goals to the command list
}

---@type MavenOptions
M.options = {}
---@return MavenOptions

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
