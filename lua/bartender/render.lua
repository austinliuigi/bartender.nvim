local render = {}
local utils = require("bartender.utils")
local highlights = require("bartender.highlights")

--- Wrap a string with its highlight group
--
---@param bar_str string Component's rendered bar string without highlights applied
---@param highlight_group? string Name of the highlight group
---@return string wrapped_bar_string Bar string wrapped with highlight group
local function wrap_highlight(bar_str, highlight_group)
  if highlight_group == nil then
    return bar_str
  end
  return "%#" .. highlight_group .. "#" .. bar_str .. "%*"
end

--- TODO
--- Wrap a string with its click function
--
---@param bar_str string Component's rendered bar string without click applied
---@param click_fn string Name of the highlight group
---@return string wrapped_bar_string Bar string wrapped with click function
local function wrap_click(bar_str, click_fn) end

--- Render the string that is used for the bar's option value
---
---@param bar bar_t The bar to render
---@return string bar_string The rendered string for the option value
function render.render(bar)
  local bar_config = require("bartender.config")[bar]

  if bar_config.disable and bar_config.disable() then
    return ""
  end

  local variant
  if utils.is_bar_local(bar) then
    variant = (require("bartender").active_winid == vim.api.nvim_get_current_win()) and "active" or "inactive"
  else
    variant = "global"
  end

  -- render bar string component by component
  local bar_text = {}
  local spec = bar_config[variant]
  for section_idx, section_spec in ipairs(spec) do
    local section = section_spec[1](unpack(utils.eval_if_func(section_spec.args or {})))

    for component_idx, component_spec in ipairs(section.components) do
      -- parse component_spec to get component
      if bar == "winbar" and section_idx == 4 then
        -- print(type(component_spec[1]))
      end
      local component
      if type(component_spec[1]) == "string" then
        component = {
          text = component_spec[1],
        }
      elseif type(component_spec[1]) == "function" then
        component = component_spec[1](unpack(utils.eval_if_func(component_spec.args or {})))
      else
        -- skip component if nil
        goto continue
      end

      -- handle highlights
      local highlight_group = nil
      if component_spec.highlight or component.highlight then
        highlight_group = highlights.create_highlight(
          bar,
          section_idx,
          component_idx,
          component.highlight or {},
          component_spec.highlight or {}
        )
      end

      -- TODO: handle click events

      local component_str = component.text
      component_str = wrap_highlight(component_str, highlight_group)
      table.insert(bar_text, component_str)

      ::continue::
    end
  end
  return table.concat(bar_text)
end

return render
