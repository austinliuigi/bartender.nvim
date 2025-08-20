local M = {}

--- Map between a bar and its default highlight group
--
local default_hl_group = {
  winbar = "WinBar",
  statusline = "StatusLine",
  tabline = "TabLineFill",
}

--- Get default highlight attributes for a bar
---
---@param bar? bartender.Bar
---@return table bar_attrs Table of hl attributes for bar (see :h nvim_get_hl)
local function default_hl_attrs(bar)
  return vim.api.nvim_get_hl(0, {
    name = default_hl_group[bar] or "Normal",
    link = false,
  })
end

--- Check if highlight group is defined
--- we don't use vim.fn.hlexists b/c it isn't accurate if a highlight is cleared due to changing colorschemes
--
---@param name string Highlight group name
---@return boolean is_defined
local function hl_exists(name)
  return not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = name, link = false }))
end

--- Return highlight attribute table of a specified group
--
---@param hl_group string Highlight group name
---@return table attrs attribute table for highlight group
local function get_hl_attrs(hl_group)
  return vim.api.nvim_get_hl(0, { name = hl_group, link = false })
end

--- Create highlight for component
---
---@param bar? bartender.Bar The bar to use for fallback highlights
---@param hl_group string Name to use for the created highlight group
---@param hl bartender.Highlight Highlights to use for created group; highest priority last
---@return table attrs Attributes of created highlight group
M.create_highlight = function(bar, hl_group, hl)
  local hl_attrs = {}
  if type(hl) == "string" then
    hl_attrs = vim.api.nvim_get_hl(0, { name = hl, link = false })
  else
    for attr, val in pairs(hl) do
      hl_attrs[attr] = require("bartender.utils").eval_if_func(val)
    end
  end

  -- inherit unspecified attributes from bar's default highlight
  local attributes = vim.tbl_deep_extend("force", default_hl_attrs(bar), hl_attrs)

  if attributes.fg == "transparent" then
    attributes.fg = require("bartender.utils").hl_attr(default_hl_group[bar], "bg")
  end

  vim.api.nvim_set_hl(0, hl_group, attributes)
  return attributes
end

--- Get the highlight group name for a component
---
---@param bar? bartender.Bar
---@param component_name string
---@param hl bartender.Highlight
---@return string hl_group Name of highlight group for component
M.get = function(bar, component_name, hl)
  local hl_group = component_name
  -- TODO: only create if necessary, i.e. when a component is updated or on colorscheme change
  --   - for now, create highlight every time to ensure it's not using a stale
  M.create_highlight(bar, hl_group, hl)
  return hl_group
end

return M
