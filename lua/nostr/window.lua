local M = {}

function M.width()
  local win_id = vim.api.nvim_get_current_win()
  local wininfo = vim.fn.getwininfo(win_id)[1]
  local width = vim.api.nvim_win_get_width(0)

  if wininfo.textoff then
    width = width - wininfo.textoff
  end

  return width
end

return M
