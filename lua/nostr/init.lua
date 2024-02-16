local window = require("nostr.window")

local M = {
  job_id = nil,
  win_id = nil,
}

local split_string_by_newline = function(str)
  local t = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(t, line)
  end
  return t
end

local timeline = function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.cmd("vsplit")

  M.win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.win_id, buf)

  local l = string.rep("─", window.width())

  local on_event = function(job_id, data, event)
    for _, line in ipairs(data) do
      if line then
        local ok, post = pcall(vim.json.decode, line)
        if ok then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { l })
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, split_string_by_newline(post.content))
        end
      end
    end
  end

  M.job_id = vim.fn.jobstart({ "algia", "stream" }, {
    on_stdout = on_event,
  })
end

local job_close = function()
  if M.job_id == nil then
    return
  end

  vim.fn.jobstop(M.job_id)
  M.job_id = nil
end

local win_close = function()
  if M.win_id == nil then
    return
  end

  if vim.api.nvim_win_is_valid(M.win_id) then
    vim.api.nvim_win_close(M.win_id, true)
  end
  M.win_id = nil
end

local close = function()
  win_close()
  job_close()
end

local post = function(text)
  vim.fn.system({ "algia", "post", text })
end

function M.setup()
  vim.api.nvim_create_user_command("Nostr", timeline, {})

  vim.api.nvim_create_user_command("NostrClose", close, {})

  vim.api.nvim_create_user_command("NostrPost", function(opts)
    post(opts.args)
  end, { nargs = "+" })
end

return M
