local utils = {}


--- Capitalize the given string
--
---@param str string to capitalize
function utils.capitalize(str)
  return (str:gsub("^%l", string.upper))
end


--- Check if supplied bar is window-local (as opposed to global)
---
---@param bar bar_t
---@return boolean
function utils.is_bar_local(bar)
  if bar == "winbar" or (bar == "statusline" and vim.o.laststatus ~= 3) then
    return true
  end
  return false
end


--- Evaluate if argument is a function, otherwise just return what was passed in
--
---@param arg any
function utils.eval_if_func(arg)
    if type(arg) == "function" then
        return arg()
    end
    return arg
end


--- Delete autogroup and any contained autocommands
---
---@param group string Name of autogroup to delete
function utils.delete_augroup(group)
  vim.api.nvim_create_augroup(group, {clear = true})
  vim.api.nvim_del_augroup_by_name(group)
end


--- Return highlight attribute of a specified group
--
---@param hl_group string Highlight group name
---@param attribute string Attribute to target
---@return string hex code
function utils.get_hightlight_attr(hl_group, attribute)
  local hl = vim.api.nvim_get_hl_by_name(hl_group, true)[attribute]
  if hl ~= nil then
    return string.format("#%06x", vim.api.nvim_get_hl_by_name(hl_group, true)[attribute])
  else
    print(attribute .. " not set for group " .. hl_group)
    return string.format("#%06x", vim.api.nvim_get_hl_by_name("Statement", true)[attribute])
  end
end


--- Check if highlight group is defined
--
---@param name string Highlight group name
---@return boolean
function utils.is_highlight_defined(name)
  -- note: define `not_defined` instead of `defined` for the lazy logic
  --   - if highlight name does not exist, `vim.api.nvim_get_hl_by_name` will error
  local not_defined = (
    vim.fn.hlexists(name) == 0 or  -- highlight has never been defined
    vim.api.nvim_get_hl_by_name(name, true).foreground == nil  -- highlight has been defined but not un-defined upon switching colorschemes
  )
  return not not_defined
end


--- Benchmark how long it takes to run function n times
---
---@param unit "seconds"|"milliseconds"|"microseconds"|"nanoseconds" Unit of time to display
---@param dec_places integer Number of decimal places to show
---@param n integer Number of times to run function
---@param f function Function to run
---@param ... any Arguments for function
function utils.benchmark(unit, dec_places, n, f, ...)
  local units = {
    ['seconds'] = 1,
    ['milliseconds'] = 1000,
    ['microseconds'] = 1000000,
    ['nanoseconds'] = 1000000000
  }
  local elapsed = 0
  local multiplier = units[unit]
  for _ = 1, n do
    local now = os.clock()
    f(...)
    elapsed = elapsed + (os.clock() - now)
  end
  print(string.format('Benchmark results:\n  - %d function calls\n  - %.'.. dec_places ..'f %s elapsed\n  - %.'.. dec_places ..'f %s avg execution time.', n, elapsed * multiplier, unit, (elapsed / n) * multiplier, unit))
end


return utils
