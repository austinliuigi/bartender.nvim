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
---@return boolean is_local
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


--- If argument is nil, return replacement, otherwise just return what was passed in
--
---@param arg any
---@param replacement? any what gets returned if arg is nil; defaults to {}
function utils.replace_nil(arg, replacement)
  replacement = replacement or {}

  if arg == nil then
    return replacement
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


--- Return highlight attribute table of a specified group
--
---@param hl_group string Highlight group name
---@return table attrs attribute table for highlight group
function utils.get_hl_attrs(hl_group)
  return vim.api.nvim_get_hl(0, {name = hl_group, link = false})
end


--- Return effective highlight attribute of a specified group
--
---@param hl_group string Highlight group name
---@param attr string Attribute to target
---@return string|nil attr value if attribute exists for hl_group else nil
function utils.get_hl_attr(hl_group, attr)
  local conversions = {
    foreground = "fg",
    background = "bg",
    special = "sp",
  }

  if conversions[attr] ~= nil then
    attr = conversions[attr]
  end

  local attrs = vim.api.nvim_get_hl(0, {name = hl_group, link = false})
  if attrs.reverse then
    local prev_fg = attrs.fg
    attrs.fg = attrs.bg
    attrs.bg = prev_fg
  end
  local val = attrs[attr]
  if val ~= nil then
    return string.format("#%06x", val)
  else
    print(string.format("bartender: %s not set for group %s", attr, hl_group))
    return nil
  end
end


--- Check if highlight group is defined
--
---@param name string Highlight group name
---@return boolean is_defined
function utils.is_highlight_defined(name)
  -- note: define `not_defined` instead of `defined` for the lazy logic
  --   - if highlight name does not exist, `vim.api.nvim_get_hl_by_name` will error
  local not_defined = (
    vim.fn.hlexists(name) == 0 or  -- highlight has never been defined
    vim.api.nvim_get_hl(0, {name = name, link = false}).fg == nil  -- highlight has been defined but not un-defined upon switching colorschemes
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


--- Find the nth match in a string; like string.find but allows targeting a specific match
--
---@param str string
---@param pattern string
---@param n integer
---@return integer|nil start start of match if found else nil
---@return integer|nil end end of match if found else nil
function utils.find_nth_match(str, pattern, n)
  local prev_start, prev_end = 0, 0
  for _ = 1, n do
    -- look for pattern starting after previous match
    prev_start, prev_end = string.find(str, pattern, prev_end + 1)
    -- early return if no match
    if prev_start == nil then
      return nil
    end
  end

  return prev_start, prev_end
end


return utils
