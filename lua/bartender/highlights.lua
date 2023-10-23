local utils = require("bartender.utils")

local highlights = {}

--- Create highlight for component
---
---@param hl_name string Name of highlight group to create
---@param component component_t
---@param section section_t
highlights.create_highlight = function(hl_name, component, section)
  -- use section's highlights for attributes not specified by component
  component.highlight = component.highlight or {}
  section.highlight = section.highlight or {}
  local attributes = vim.tbl_deep_extend('keep', component.highlight, section.highlight)

  -- make reverse work with transparency by doing it manually
  -- (o.w. when fg is nil, it gets converted to Normal's highlight before reverse takes effect)
  if attributes.reverse ~= nil then
    attributes.reverse = nil
    local prev_fg = attributes.fg
    attributes.fg = attributes.bg
    attributes.bg = prev_fg
  end

  vim.api.nvim_set_hl(0, hl_name, attributes)
end

--- Get name of highlight group for component
---
---@param bar string
---@param section_index integer Index of section in bar
---@param component_index integer Index of component in bar
---@return string Name of component's highlight group
highlights.get_highlight_name = function(bar, section_index, component_index)
  local name
  if utils.is_bar_local(bar) then
    name = string.format("Bartender%sWindow%sSection%sComponent%s", utils.capitalize(bar), vim.api.nvim_get_current_win(), section_index, component_index)
  else
    name = string.format("Bartender%s%sSection%sComponent%s", utils.capitalize(bar), section_index, component_index)
  end
  return name
end

return highlights
