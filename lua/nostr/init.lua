local M = {}

M.job_id = nil
M.win_id = nil

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

  local on_event = function(job_id, data, event)
    for _, line in ipairs(data) do
      if line then
        local ok, post = pcall(vim.json.decode, line)
        if ok then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "------------------------" })
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, split_string_by_newline(post.content))
        end
      end
    end
  end

  M.job_id = vim.fn.jobstart({ "algia", "stream" }, {
    on_stdout = on_event,
  })
end

local close = function()
  if M.job_id == nil or M.win_id == nil then
    return
  end

  vim.fn.jobstop(M.job_id)
  vim.api.nvim_win_close(M.win_id, true)

  M.job_id = nil
  M.win_id = nil
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
