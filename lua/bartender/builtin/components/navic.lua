local utils = require("bartender.utils")
local nvim_navic_ok, nvim_navic = pcall(require, "nvim-navic")
if not nvim_navic_ok then
  vim.notify("bartender: unable to load nvim-navic", vim.log.levels.ERROR)
  return nil
end
local navic = {}


--- Remove the highlight components from a bar format string
--
---@param bar_str string
---@return string Stripped format string
local function strip_highlights(bar_str)
  bar_str, _ = bar_str:gsub("%%%*", ""):gsub("%%%#.-%#", "")
  return bar_str
end


--- Navic string that shows the lsp document symbols that cursor is in
---   - requires nvim-navic to be installed
---   - requires nvim-navic to be attached to the lsp server
--
---@param max_chars integer Max number of chars that component should take up; truncation occurs until it fits
---@param ellipsis string String that should show if truncated, e.g. ".."
function navic.provider(max_chars, ellipsis)
  max_chars = max_chars or (vim.api.nvim_win_get_width(0)/3)
  max_chars = (max_chars < 0) and 0 or max_chars  -- minimum max_chars == 0

  ellipsis = ellipsis or ".."
  ellipsis = "%#NavicText#"..ellipsis  -- highlight ellipsis the same as other navic text

  local code_context = nvim_navic.get_location()
  while vim.fn.strchars(strip_highlights(code_context)) > max_chars do
    -- local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    local next_section, _ = utils.find_nth_match(code_context, "%%%#NavicSeparator%#", 2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
  end

  return {
    text = code_context,
  }, { "CursorMoved" }
end


return navic
