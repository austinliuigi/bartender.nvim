--- Navic string that shows the lsp document symbols that cursor is in
---   - requires nvim-navic to be installed
---   - requires nvim-navic to be attached to the lsp server

local nvim_navic_ok, nvim_navic = pcall(require, "nvim-navic")
if not nvim_navic_ok then
  vim.notify("bartender: unable to load nvim-navic", vim.log.levels.ERROR)
  return nil
end

--- Remove the highlight components from a bar format string
--
---@param bar_str string
---@return string Stripped format string
local function strip_highlights(bar_str)
  bar_str, _ = bar_str:gsub("%%%*", ""):gsub("%%%#.-%#", "")
  return bar_str
end

--- Find the nth match in a string; like string.find but allows targeting a specific match
--
---@param str string
---@param pattern string
---@param n integer
---@return integer|nil start start of match if found else nil
---@return integer|nil end end of match if found else nil
local function find_nth_match(str, pattern, n)
  local prev_start, prev_end = 0, 0
  for _ = 1, n do
    -- look for pattern starting after previous match
    prev_start, prev_end = string.find(str, pattern, prev_end + 1)
    -- early return if no match
    if prev_start == nil then
      return nil
    end
  end

  return prev_start, prev_end
end

---@param ellipsis string String that should show if truncated, e.g. ".."
---@param max_chars integer Max number of chars that component should take up; truncation occurs until it fits
return function(ellipsis, max_chars)
  max_chars = math.max(0, max_chars or (vim.api.nvim_win_get_width(0) / 3))

  ellipsis = ellipsis or ".."
  ellipsis = "%#NavicText#" .. ellipsis -- highlight ellipsis the same as other navic text

  local code_context = nvim_navic.get_location()
  while vim.fn.strchars(strip_highlights(code_context)) > max_chars do
    -- local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    local next_section, _ = find_nth_match(code_context, "%%%#NavicSeparator%#", 2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
  end

  return {
    code_context,
  }, { "CursorMoved" }
end
