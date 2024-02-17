local M = {}

function M.concat(...)
  local result = {}
  for _, array in ipairs({ ... }) do
    for _, value in ipairs(array) do
      table.insert(result, value)
    end
  end
  return result
end

return M
