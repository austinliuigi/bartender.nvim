local M = {}
local utils = require("bartender.utils")

--- Capitalize the given string
--
---@param str string to capitalize
local function capitalize(str)
  return (str:gsub("^%l", string.upper))
end

--- Wrap a string with its highlight group
--
---@param component_str string
---@param hl_group? string
---@return string wrapped_component_string
local function wrap_hl(component_str, hl_group)
  return "%#" .. hl_group .. "#" .. component_str .. "%*"
end

--- Wrap a string with its click function
---
---@param component_str string
---@param click_str? string e.g. v:lua.component_click_handler
---@return string wrapped_component_str
local function wrap_click(component_str, click_str)
  return "%@" .. click_str .. "@" .. component_str .. "%X"
end

---@param tbl table
---@return boolean
local function has_call_metamethod(tbl)
  local mt = getmetatable(tbl)
  if mt then
    return mt.__call ~= nil
  end
  return false
end

--- Get the type of a component
---
---@param component bartender.Component
---@return "static"|"dynamic"|"group"
local function component_type(component)
  local t = type(component[1])
  if t == "table" then
    ---@diagnostic disable-next-line: param-type-mismatch
    if has_call_metamethod(component[1]) then
      return "dynamic"
    end
    return "group"
  elseif t == "function" then
    return "dynamic"
  else
    return "static"
  end
end

--- Resolve the option string for a static component
---
---@param component bartender.StaticComponent
---@param bar? bartender.Bar
---@param parent_name? string
---@param nth_child integer
---@return string
local function resolve_static_component(component, bar, parent_name, nth_child)
  parent_name = parent_name or "Bartender"
  nth_child = nth_child or 1

  local name = string.format("%s_%s", parent_name, nth_child)

  local component_str = component[1]

  local hl = utils.eval_if_func(component.hl)
  if hl ~= nil then
    component_str = wrap_hl(component_str, require("bartender.highlight").get(bar, name, hl))
  end

  if component.on_click ~= nil then
    component_str = wrap_click(component_str, require("bartender.click").get(name, component.on_click))
  end
  return component_str
end

--- Resolve the option string for a dynamic component
---
---@param component bartender.DynamicComponent
---@param bar? bartender.Bar
---@param parent_name? string
---@param nth_child integer
---@return string
local function resolve_dynamic_component(component, bar, parent_name, nth_child)
  parent_name = parent_name or "Bartender"
  nth_child = nth_child or 1

  -- if cached then
  --   use_cache
  -- else
  --   create autocmd to check cache
  -- end

  local evaled_component = component[1](unpack(utils.eval_if_func(component.args or {})))

  -- highlight override
  if component.hl ~= nil then
    evaled_component.hl = component.hl
  end

  -- on_click override
  if component.on_click ~= nil then
    evaled_component.on_click = component.on_click
  end

  return M.resolve_component(evaled_component, bar, parent_name, nth_child)
end

--- Resolve the option string for a component group
---
---@param component_group bartender.ComponentGroup
---@param bar? bartender.Bar
---@param parent_name? string
---@param nth_child? integer
---@return string
local function resolve_component_group(component_group, bar, parent_name, nth_child)
  parent_name = parent_name or "Bartender"
  nth_child = nth_child or 1
  local name = string.format("%s_%s", parent_name, nth_child)

  local component_strings = {}
  for n, component in ipairs(component_group) do
    if component_group.on_click ~= nil then
      -- on_click override
      component.on_click = component_group.on_click
    end
    table.insert(component_strings, M.resolve_component(component, bar, name, n))
  end
  return table.concat(component_strings)
end

--- Resolve the option string for a component or component group
---
---@param component bartender.Component|bartender.ComponentGroup
---@param bar? bartender.Bar
---@param parent_name? string
---@param nth_child? integer
---@return string
function M.resolve_component(component, bar, parent_name, nth_child, test)
  local t = component_type(component)
  if test == true then
    print(t, "foo")
  end
  if t == "static" then
    ---@diagnostic disable-next-line: param-type-mismatch
    return resolve_static_component(component, bar, parent_name, nth_child)
  elseif t == "dynamic" then
    ---@diagnostic disable-next-line: param-type-mismatch
    return resolve_dynamic_component(component, bar, parent_name, nth_child)
  else
    return resolve_component_group(component, bar, parent_name, nth_child)
  end
end

--- Resolve the string that is used for a bar's option value
---
---@param bar bartender.Bar The bar to resolve
---@return string bar_string The resolved string for the option value
function M.resolve_bar(bar)
  local bar_config = require("bartender.config")[bar]

  if type(bar_config.disable) == "function" and bar_config.disable() == true then
    return ""
  end

  local name
  local variant
  if utils.is_bar_local(bar) then
    local current_win = vim.api.nvim_get_current_win()
    variant = (require("bartender").active_winid == current_win) and "active" or "inactive"
    name = string.format("Bartender%sW%s", capitalize(bar), current_win)
  else
    variant = "global"
    name = string.format("Bartender%s", capitalize(bar))
  end

  local variant_config = bar_config[variant]

  return resolve_component_group(variant_config, bar, name)
end

return M
