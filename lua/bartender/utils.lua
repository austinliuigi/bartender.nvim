local M = {}

--- Check if supplied bar is window-local (as opposed to global)
---
---@param bar bartender.Bar
---@return boolean is_local
function M.is_bar_local(bar)
  if bar == "winbar" or (bar == "statusline" and vim.o.laststatus ~= 3) then
    return true
  end
  return false
end

--- Evaluate if argument is a function, otherwise just return what was passed in
--
---@param arg any
function M.eval_if_func(arg)
  if type(arg) == "function" then
    return arg()
  end
  return arg
end

--- Get effective highlight attribute of a specified group
--
---@param hl_group string Highlight group name
---@param attr string Attribute to target
---@return string|nil attr Value if attribute exists for hl_group else nil
function M.hl_attr(hl_group, attr)
  local attrs = vim.api.nvim_get_hl(0, { name = hl_group, link = false })
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

return M
