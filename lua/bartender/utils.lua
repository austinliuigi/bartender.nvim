local utils = {}

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

--- Return highlight attribute table of a specified group
--
---@param hl_group string Highlight group name
---@return table attrs attribute table for highlight group
function utils.get_hl_attrs(hl_group)
  return vim.api.nvim_get_hl(0, { name = hl_group, link = false })
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

--- Check if highlight group is defined
--
---@param name string Highlight group name
---@return boolean is_defined
function utils.is_highlight_defined(name)
  -- note: the evaluation order matters because of the short circuit
  --   - if highlight name does not exist, `vim.api.nvim_get_hl_by_name` will error
  local not_defined = (
    vim.fn.hlexists(name) == 0 -- highlight has never been defined
    or vim.api.nvim_get_hl(0, { name = name, link = false }).fg == nil -- highlight has been defined but not un-defined upon switching colorschemes
  )
  return not not_defined
end

return utils
