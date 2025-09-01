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

--- Create autocommands that clear a dynamic component and its evaluated component from the cache
---
---@param dynamic_component_cache_name string
---@param events bartender.Events
---@param bar bartender.Bar?
local function create_update_autocmds(dynamic_component_cache_name, events, bar)
  local function register(event, pattern)
    vim.api.nvim_create_autocmd(event, {
      group = dynamic_component_cache_name,
      pattern = pattern,
      callback = function()
        -- special case: since statuscolumn only has one autocmd per window, but each line has a
        --  cache entry, we need to remove all of the line's entries for the component in this autocmd
        if bar == "statuscolumn" then
          -- all cache entries of the descendants and derivatives of the dynamic component are captured by this pattern
          local pat = dynamic_component_cache_name:gsub("L1V0", "L%%d+V%%d+")
          require("bartender.cache").clear(pat)
        else
          require("bartender.cache").remove(dynamic_component_cache_name)
        end
      end,
    })
  end

  if type(events) == "string" then
    register(events)
  else
    for _, event in ipairs(events) do
      if type(event) == "string" then
        register(event)
      else
        register(event[1], event[2])
      end
    end
  end
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
---@param name? string
---@return string
local function resolve_static_component(component, bar, name)
  name = name or "Bartender"

  local component_str = component[1]

  -- return cached component if exists
  local current_cache_entry = require("bartender.cache").cache[name]
  if current_cache_entry then
    if type(component.hl) == "function" then
      require("bartender.highlight").create(name, bar, component.hl)
    end
    return current_cache_entry.str
  end

  -- create new cache entry
  local cache_entry = {}
  require("bartender.cache").cache[name] = cache_entry

  -- handle highlight
  if component.hl ~= nil then
    local hl_group = require("bartender.highlight").create(name, bar, component.hl)
    cache_entry.hl = hl_group
    component_str = wrap_hl(component_str, hl_group)
  end

  -- handle click
  if component.on_click ~= nil then
    cache_entry.click_fn = component.on_click
    component_str = wrap_click(component_str, string.format("v:lua.require'bartender.cache'.cache.%s.click_fn", name))
  end

  cache_entry.str = component_str
  return component_str
end

--- Resolve the option string for a dynamic component
---
---@param component bartender.DynamicComponent
---@param bar? bartender.Bar
---@param name? string
---@return string
local function resolve_dynamic_component(component, bar, name)
  name = name or "Bartender"

  local cache_name = name
  local evaled_component_name = string.format("%s%s", name, "d") -- "d" to signify that it is derived from a function

  -- use cached component if exists
  local current_cache_entry = require("bartender.cache").cache[cache_name]
  if current_cache_entry then
    if current_cache_entry.update_on_redraw then
      require("bartender.cache").remove(cache_name)
    else
      return M.resolve_component(current_cache_entry.evaled_component, bar, evaled_component_name)
    end
  end

  -- create new cache entry
  ---@type bartender.CachedDynamicComponent
  ---@diagnostic disable-next-line: missing-fields
  local cache_entry = {}
  require("bartender.cache").cache[cache_name] = cache_entry

  -- evaluate and cache resulting component
  local evaled_component, update_events = component[1](unpack(utils.eval_if_func(component.args or {})))
  cache_entry.evaled_component = evaled_component
  cache_entry.evaled_component_name = evaled_component_name

  if update_events then
    -- for statuscolumn, only create update autocmd for each window, otherwise each *line* of each
    -- window would create an autocmd
    if bar ~= "statuscolumn" or name:match("L1V0") then
      cache_entry.augroup_id = vim.api.nvim_create_augroup(cache_name, { clear = true })
      create_update_autocmds(cache_name, update_events, bar)
    end
  else
    cache_entry.update_on_redraw = true
  end

  -- highlight override
  if component.hl ~= nil then
    evaled_component.hl = component.hl
  end

  -- on_click override
  if component.on_click ~= nil then
    evaled_component.on_click = component.on_click
  end

  local component_str = M.resolve_component(evaled_component, bar, evaled_component_name)

  return component_str
end

--- Resolve the option string for a component group
---
---@param component_group bartender.ComponentGroup
---@param bar? bartender.Bar
---@param name? string
---@return string
local function resolve_component_group(component_group, bar, name)
  name = name or "Bartender"

  local cache_entry = {}
  require("bartender.cache").cache[name] = cache_entry

  local component_strs = {}
  local children_names = {}
  for n, component in ipairs(component_group) do
    -- on_click override
    if component_group.on_click ~= nil then
      component.on_click = component_group.on_click
    end

    local child_name = string.format("%s_%s", name, n)
    table.insert(children_names, child_name)
    table.insert(component_strs, M.resolve_component(component, bar, child_name))
  end
  cache_entry.children = children_names

  -- NOTE: We store the string in the cache entry only for inspection purposes
  --   - we don't use it to early return on future invocations because we need to recurse all
  --     children in case any need to be updated
  local component_str = table.concat(component_strs)
  cache_entry.str = component_str

  return component_str
end

--- Resolve the option string for a component or component group
---
---@param component bartender.Component|bartender.ComponentGroup
---@param bar? bartender.Bar
---@param name? string
---@return string
function M.resolve_component(component, bar, name)
  local t = component_type(component)
  if t == "static" then
    ---@diagnostic disable-next-line: param-type-mismatch
    return resolve_static_component(component, bar, name)
  elseif t == "dynamic" then
    ---@diagnostic disable-next-line: param-type-mismatch
    return resolve_dynamic_component(component, bar, name)
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    return resolve_component_group(component, bar, name)
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
    if bar == "statuscolumn" then
      name = string.format("%sL%sV%s", name, vim.v.lnum, vim.v.virtnum)
    end
  else
    variant = "global"
    name = string.format("Bartender%s", capitalize(bar))
  end

  local variant_config = bar_config[variant]

  return M.resolve_component(variant_config, bar, name)
end

return M
