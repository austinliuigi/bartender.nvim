local utils = require("bartender.utils")

local M = {}

local tab_hl = "TabLine"
local curr_tab_hl = "TabLineSel"
local tab_fill = "TabLineFill"

local is_current_tab = function(tab_number)
  if tab_number == vim.fn.tabpagenr() then
    return true
  end
  return false
end

M.get_tab_symbol = function(tab_number)
  local current = is_current_tab(tab_number)
  return {
    text = current and " " or " ",
    highlight = {
      name = current and curr_tab_hl or tab_hl
    }
  }
end

M.get_tab_name = function(tab_number)
  local current = is_current_tab(tab_number)
  return {
    text = tab_number,
    highlight = {
      name = current and curr_tab_hl or tab_hl
    }
  }
end

M.get_tab_separator_left = function(tab_number)
  local current = is_current_tab(tab_number)
  return {
    text = " ",
    highlight = {
      name = "TabSeparator",
      attributes = {
        fg = utils.get_hl(tab_hl, "background"),
      }
    }
  }
end

M.get_tab_separator_right = function(tab_number)
  local current = is_current_tab(tab_number)
  return {
    text = " ",
    highlight = {
      name = current and "TabSeparatorCurrent" or "TabSeparator",
      attributes = {
        fg = utils.get_hl(current and curr_tab_hl or tab_hl, "background"),
      }
    }
  }
end

M.get_tab_space = function(tab_number)
  local current = is_current_tab(tab_number)
  return {
    text = " ",
    highlight = {
      name = current and "TabSeparatorCurrent" or "TabSeparator",
      attributes = {
        fg = utils.get_hl(current and curr_tab_hl or tab_hl, "background"),
      }
    }
  }
end

M.get_buffers = function()
end

M.debug = function()
  print(tab_hl)
end

return M
