local components = require("bartender.builtin.tabline.components")

local M = {}

M.tabs = function()
  local tabs = {}

  for tab = 1, vim.fn.tabpagenr("$") do
    table.insert(tabs, components.get_tab_separator_left(tab))
    table.insert(tabs, components.get_tab_symbol(tab))
    table.insert(tabs, components.get_tab_name(tab))
    table.insert(tabs, components.get_tab_separator_right(tab))
  end

  return {
    bg = nil,
    components = tabs,
  }
end

return M
