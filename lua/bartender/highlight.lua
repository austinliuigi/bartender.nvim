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

--- Create highlight group for component
---
---@param hl_group string Name to use for the created highlight group
---@param bar? bartender.Bar The bar to use for fallback highlights
---@param hl bartender.Highlight Highlights to use for created group; highest priority last
---@return string
M.create = function(hl_group, bar, hl)
  hl = require("bartender.utils").eval_if_func(hl)

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
  return hl_group
end

return M
