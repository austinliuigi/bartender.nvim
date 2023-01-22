local config = require("bartender.config")

local M = {}

--- Create highlight for component
---
---@param name string Name of highlight group
---@param component table Table that component returns
---@param background string #RRGGBB of background to use
M.create_highlight = function(name, component, background)
  if component.highlight.devicon == true then
    -- TODO: Only create highlight for current filetype
    -- Remove group corresponding to current buffer from name
    name = string.gsub(name, M.get_current_devicon_group().."$", "")
    for _, icon_table in pairs(require("nvim-web-devicons").get_icons()) do
      vim.api.nvim_set_hl(0, name..icon_table.name, { fg = icon_table.color, bg = background })
    end
  else
    -- Use section's background if one was not specified for component
    local attributes = vim.tbl_deep_extend('keep', component.highlight, { bg = background })
    -- Make reverse work with transparency by doing it manually
    -- (o.w. when fg is nil, it gets converted to Normal's highlight before reverse takes effect)
    if attributes.reverse ~= nil then
      attributes.reverse = nil
      local prev_fg = attributes.fg
      attributes.fg = attributes.bg
      attributes.bg = prev_fg
    end
    vim.api.nvim_set_hl(0, name, attributes)
  end
end

--- Get name of highlight group for component
---
---@param bar string
---@param variant string
---@param section_index int Index of section in bar
---@param section table Table that section returns
---@param component_index int Index of component in bar
---@param component table Table that component returns
M.get_highlight_name = function(bar, section_index, section, component_index, component)
  local name = string.format("Bartender%sSection%sComponent%s", require("bartender.utils").capitalize(bar), section_index, component_index)
  if component.highlight.devicon == true then
    -- Append group name corresponding to current buffer
    name = name .. M.get_current_devicon_group()
  end
  return name
end

M.get_current_devicon_group = function()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local _, group = require("nvim-web-devicons").get_icon(filename, fileext, { default = true })
  group = string.gsub(group, "^DevIcon", "")
  return group
end

return M
