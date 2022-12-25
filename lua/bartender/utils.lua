local M = {}

-- Return highlight attribute of a specified group
-- @param group highlight group name
-- @param attribute attribute to target
-- @return string hex code
M.get_hl = function (group, attribute)
  local hl = vim.api.nvim_get_hl_by_name(group, true)[attribute]
  if hl ~= nil then
    return string.format("#%06x", vim.api.nvim_get_hl_by_name(group, true)[attribute])
  else
    print(attribute .. " not set for group " .. group)
    return string.format("#%06x", vim.api.nvim_get_hl_by_name("Statement", true)[attribute])
  end
end

return M
