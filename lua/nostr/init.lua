local array = require("nostr.array")
local strings = require("nostr.strings")
local window = require("nostr.window")

local M = {
  job_id = nil,
  win_id = nil,
}

local read_file = function(filename)
  local file, err = io.open(filename, "r")
  if not file then
    return nil, err
  end

  local content = file:read("a")
  file:close()

  return content, nil
end

-- TODO: do with each OS
local read_config = function()
  local config_path = string.format("%s/.config/algia/config.json", os.getenv("HOME"))
  local content, err = read_file(config_path)
  if not content then
    return nil, err
  end

  local ok, config = pcall(vim.json.decode, content)
  if not ok then
    return nil, "failed to decode config json."
  end
  return config, nil
end

local timeline = function()
  local config, err = read_config()
  if not config then
    error(err, 1)
  end

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
          local lines = array.concat({
            l,
            string.format("%s %s", config.follows[post.pubkey].name, os.date("%Y-%m-%d %H:%M:%S", post.created_at)),
            "",
          }, strings.split_new_line(post.content))
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
        end
      end
    end
  end

  M.job_id = vim.fn.jobstart({ "algia", "stream", "--follow" }, {
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
