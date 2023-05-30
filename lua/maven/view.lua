---@class LogView
---@field buf number
---@field win number
local View = {}

View.__index = View

local function find_rogue_buffer()
  for _, v in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(v) == "Maven" then
      return v
    end
  end
  return nil
end

function View.create()
  vim.cmd("below new")
  local buf = View:new()
  buf:setup()
  return buf
end

function View:new()
  local this = {
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
  }
  setmetatable(this, self)
  return this
end

function View:set_option(name, value, win)
  if win then
    return vim.api.nvim_set_option_value(name, value, { win = self.win, scope = "local" })
  else
    return vim.api.nvim_set_option_value(name, value, { buf = self.buf })
  end
end

function View:setup()
  vim.cmd("setlocal nonu")
  vim.cmd("setlocal nornu")

  if not pcall(vim.api.nvim_buf_set_name, self.buf, "Maven") then
    View:clear_buf()
    vim.api.nvim_buf_set_name(self.buf, "Maven")
  end

  self:set_option("filetype", "Maven")
  self:set_option("bufhidden", "wipe")
  self:set_option("buftype", "nofile")
  self:set_option("swapfile", false)
  self:set_option("buflisted", false)
  self:set_option("winfixwidth", true, true)
  self:set_option("wrap", false, true)
  self:set_option("spell", false, true)
  self:set_option("list", false, true)
  self:set_option("winfixheight", true, true)
  self:set_option("signcolumn", "no", true)
  self:set_option("foldmethod", "manual", true)
  self:set_option("foldcolumn", "0", true)
  self:set_option("foldlevel", 3, true)
  self:set_option("foldenable", false, true)
  self:set_option("fcs", "eob: ", true)

  vim.api.nvim_buf_set_keymap(self.buf, "n", "q", "<cmd>close<cr>", { silent = true, noremap = true, nowait = true })
  vim.api.nvim_buf_set_keymap(self.buf, "n", "<esc>", "<cmd>close<cr>", { silent = true, noremap = true, nowait = true })
end

function View:clear_buf()
  local bn = find_rogue_buffer()
  if bn then
    local win_ids = vim.fn.win_findbuf(bn)
    for _, id in ipairs(win_ids) do
      if vim.fn.win_gettype(id) ~= "autocmd" and vim.api.nvim_win_is_valid(id) then
        vim.api.nvim_win_close(id, true)
      end
    end

    vim.schedule(function()
      pcall(vim.api.nvim_buf_delete, bn, {})
    end)
  end
end

function View:render_line(line)
  vim.schedule(function()
    vim.fn.appendbufline(self.buf, vim.fn.line("$"), line)
    vim.api.nvim_command("cbottom")
  end)
end

return View
