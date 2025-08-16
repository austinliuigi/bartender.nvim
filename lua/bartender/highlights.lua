local highlights = {}

--- Capitalize the given string
--
---@param str string to capitalize
local function capitalize(str)
  return (str:gsub("^%l", string.upper))
end

--- Map between a bar and its default highlight group
--
highlights.default_hl_groups = {
  winbar = "WinBar",
  statusline = "StatusLine",
  tabline = "TabLineFill",
}

--- Get default highlight attributes for a bar
---
---@param bar string
---@return table bar_attrs Table of hl attributes for bar (see :h nvim_get_hl)
function highlights.get_default_hl_attrs(bar)
  return vim.api.nvim_get_hl(0, {
    name = highlights.default_hl_groups[bar],
    link = false,
  })
end

--- Get name of highlight group for component
---
---@param bar string
---@param section_index integer Index of section in bar
---@param component_index integer Index of component in bar
---@return string component_hl_name Name of component's highlight group
highlights.get_highlight_name = function(bar, section_index, component_index)
  local name
  if require("bartender.utils").is_bar_local(bar) then
    name = string.format(
      "Bartender%sWindow%sSection%sComponent%s",
      capitalize(bar),
      vim.api.nvim_get_current_win(),
      section_index,
      component_index
    )
  else
    name = string.format("Bartender%sSection%sComponent%s", capitalize(bar), section_index, component_index)
  end
  return name
end

--- Convert highlights to attribute tables
--
---@param hl_list (string|table)[] List of highlight group names or attribute tables
---@return table attrs_list Same as input but converted to attribute tables
highlights.highlights_to_attrs = function(hl_list)
  local attrs_list = {}
  for _, hl in ipairs(hl_list) do
    if type(hl) == "string" then
      hl = require("bartender.utils").get_hl_attrs(hl)
    end
    table.insert(attrs_list, hl)
  end
  return attrs_list
end

--- Create highlight for component
---
---@param bar string
---@param section_index integer Index of section in bar
---@param component_index integer Index of component in bar
---@param ... string|table Highlight group names or attribute tables; highest priority last
---@return string hl_group Name of created highlight group
highlights.create_highlight = function(bar, section_index, component_index, ...)
  local hl_group = highlights.get_highlight_name(bar, section_index, component_index)

  -- inherit unspecified attributes from bar's default highlight
  -- note: "force" is not an arbitrary decision; it is needed so that unpack() uses all return values since it is the last arg
  local attributes =
    vim.tbl_deep_extend("force", highlights.get_default_hl_attrs(bar), unpack(highlights.highlights_to_attrs({ ... })))

  -- perform reverse manually to dodge unexpected behavior
  --   - when fg is nil, bg should be nil after reverse
  --     (instead of the fg of highlight-group "Normal")
  --   - when bg is nil, fg should be bg of highlight-group "Normal" after reverse
  --     (instead of nil, which neovim interprets as fg of highlight-group "Normal")
  if attributes.reverse then
    attributes.reverse = nil -- unset reverse since we are doing it manually

    -- explicitly interpolate bg of highlight-group "Normal"
    if attributes.bg == nil then
      attributes.bg = vim.api.nvim_get_hl(0, {
        name = "Normal",
        link = false,
      })["bg"]
    end

    -- swap fg and bg
    local prev_fg = attributes.fg
    attributes.fg = attributes.bg
    attributes.bg = prev_fg
  end

  vim.api.nvim_set_hl(0, hl_group, attributes)
  return hl_group
end

return highlights
