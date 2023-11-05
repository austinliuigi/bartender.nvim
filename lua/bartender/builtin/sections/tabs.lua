local utils = require("bartender.utils")
local components = require("bartender.builtin.components")
local tabs = {}

local function sep_hl_active()
  return {
    fg = utils.get_hl_attr("TabLineSel", "bg"),
    bg = utils.get_hl_attr("TabLineFill", "bg"),
  }
end
local function sep_hl_inactive()
  return {
    fg = utils.get_hl_attr("TabLine", "bg"),
    bg = utils.get_hl_attr("TabLineFill", "bg"),
  }
end

function tabs.provider()
  local component_list = {
    { "    ", highlight = "TabLine" },
    { "", highlight = sep_hl_inactive() },
  }

  for tabpagenr = 1, vim.fn.tabpagenr("$") do
    local tab_components
    if tabpagenr == vim.fn.tabpagenr() then
      tab_components = {
        { "", highlight = sep_hl_active() },
        { "  "..tabpagenr.." ", highlight = "TabLineSel" },
        { components.filepath,
          args = function()
            return {vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(vim.api.nvim_list_tabpages()[tabpagenr])), ":t"}
          end,
          highlight = "TabLineSel" },
        { " ", highlight = "TabLineSel" },
        { "", highlight = sep_hl_active() },
      }
    else
      tab_components = {
        { "", highlight = sep_hl_inactive() },
        { "  "..tabpagenr.." ", highlight = "TabLine" },
        { components.filepath,
          args = function()
            return {vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(vim.api.nvim_list_tabpages()[tabpagenr])), ":t"}
          end,
          highlight = "TabLine" },
        { " ", highlight = "TabLine" },
        { "", highlight = sep_hl_inactive() },
      }
    end

    for _, component in ipairs(tab_components) do
      table.insert(component_list, component)
    end
  end

  return {
    components = component_list
  }
end


return tabs
