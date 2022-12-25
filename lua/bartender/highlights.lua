local utils = require("bartender.utils")
local config = require("bartender.config")

local M = {}

-- Relevant winbar colors
M.colors = function()
  return {
    left_bg   = nil,
    center_bg = utils.get_hl("Comment", "foreground"),
    right_bg   = nil,
  }
end

-- @param components table {}
M.set_highlights = function(components, background)
  for _, component in ipairs(components) do
    -- Define highlight group if component is devicon
    if component.highlight.devicon == true then
      for _, icon_table in pairs(require("nvim-web-devicons").get_icons()) do
        vim.api.nvim_set_hl(0, config.highlight_prefix .. "DevIcon".. icon_table.name, { fg = icon_table.color, bg = background })
      end
    -- Define a highlight group for component if attributes field is non-nil
    elseif component.highlight.attributes ~= nil then
      -- Use section's background if one was not specified for component
      local attributes = vim.tbl_deep_extend('keep', component.highlight.attributes, { bg = background })
      -- Swap fg and bg values if specified (for borders)
      if component.highlight.reverse == true then
        local prev_fg = attributes.fg
        attributes.fg = attributes.bg
        attributes.bg = prev_fg
      end
      vim.api.nvim_set_hl(0, config.highlight_prefix .. component.highlight.name, attributes)
    end
  end
end

M.get_highlight = function(component)
  if component.highlight.attributes ~= nil or component.highlight.devicon ~= nil then
    return config.highlight_prefix .. component.highlight.name
  else
    return component.highlight.name
  end
end

return M
