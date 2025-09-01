local M = {}

--- Check if supplied bar is window-local (as opposed to global)
---
---@param bar bartender.Bar
---@return boolean is_local
function M.is_bar_local(bar)
  if bar == "winbar" or bar == "statuscolumn" or (bar == "statusline" and vim.o.laststatus ~= 3) then
    return true
  end
  return false
end

--- Evaluate if argument is a function, otherwise just return what was passed in
---
---@param arg any
function M.eval_if_func(arg)
  if type(arg) == "function" then
    return arg()
  end
  return arg
end

--- Get effective highlight attributes of highlight
---
---@param hl bartender.Highlight
---@return table
function M.get_effective_hl_attrs(hl)
  local attrs = M.eval_if_func(hl)
  if type(hl) == "string" then
    attrs = vim.api.nvim_get_hl(0, { name = hl, link = false })
  end

  -- neovim inherits from Normal hl-group if fg or bg of a highlight is nil
  attrs.fg = attrs.fg or vim.api.nvim_get_hl(0, {
    name = "Normal",
    link = false,
  })["fg"]
  attrs.bg = attrs.bg or vim.api.nvim_get_hl(0, {
    name = "Normal",
    link = false,
  })["bg"]

  if attrs.reverse then
    attrs.reverse = nil -- unset reverse since we are doing it manually

    local prev_fg = attrs.fg
    attrs.fg = attrs.bg
    attrs.bg = prev_fg
  end
  return attrs
end

--- Get effective highlight attribute of a specified group
---
---@param hl_group string Highlight group name
---@param attr string Attribute to target
---@return string|nil attr Value if attribute exists for hl_group else nil
function M.hl_attr(hl_group, attr)
  local attrs = M.get_effective_hl_attrs(hl_group)
  local val = attrs[attr]
  if val ~= nil then
    return string.format("#%06x", val)
  else
    print(string.format("bartender: %s not set for group %s", attr, hl_group))
    return nil
  end
end

---@param hl_group string Highlight group name
---@param attr string Attribute to target
---@return fun(): string?
function M.hl_attr_wrap(hl_group, attr)
  return function()
    return M.hl_attr(hl_group, attr)
  end
end

---@param specs table<string, string[]> Table containing hl_attr to { hl_group, hl_attr } pairs
---@return fun(): table<string, fun(): string?>
function M.hl_attrs_wrap(specs)
  return function()
    local attrs = {}
    for attr, spec in pairs(specs) do
      attrs[attr] = M.hl_attr(unpack(spec))
    end
    return attrs
  end
end

---@param basename string
---@param start? integer
---@param stop? integer
function M.get_cached_component_width(basename, start, stop)
  start = start or 1
  stop = stop or start

  local width = 0
  for i = start, stop do
    local cache_entry = require("bartender.cache").cache[string.format("%s_%s", basename, i)]
    if cache_entry == nil then
      goto continue
    elseif cache_entry.str == nil then
      -- if cached component is that of a dynamic component, use the cached derivation instead
      cache_entry = require("bartender.cache").cache[cache_entry.evaled_component_name]
    end
    width = width + vim.api.nvim_eval_statusline(cache_entry.str, {}).width
    ::continue::
  end
  return width
end

return M
