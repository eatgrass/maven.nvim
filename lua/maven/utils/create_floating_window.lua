local M = {}

local message = "Paste the dependency here and press enter to add it to the pom.xml."

-- Function to create the floating window where the user will paste the dependency
function M.create_floating_window()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 80,
    height = 10,
    row = 10,
    col = 10,
    style = "minimal",
    border = "rounded",
  })
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message, "" })
  vim.api.nvim_win_set_cursor(win, { 2, 0 })

  return buf, win
end

-- Function to remove instruction message when user starts typing
function M.remove_instruction(buf, win)
  local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
  if first_line == message then
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, {})
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
end

return M
