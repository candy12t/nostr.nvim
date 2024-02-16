local M = {}

function M.split(str, regexp)
  local t = {}
  for line in str:gmatch(regexp) do
    table.insert(t, line)
  end
  return t
end

function M.split_new_line(str)
  return M.split(str, "[^\r\n]+")
end

return M
