local highlights = require("bartender.highlights")
local utils = require("bartender.utils")
local _config = require("bartender.config")

---@alias bar_t "winbar"|"statusline"|"tabline"
---@alias variant_t "active"|"inactive"|"global"
local BARS = { "winbar", "statusline", "tabline", }
local VARIANTS = { "active", "inactive", "global" }

---@class component_t
---@field text string text that should be shown on bar
---@field highlight (string|table)? highlight group or attribute table component should take on
---@field click function?

---@class component_spec
---@field [1] fun(): component_t, events function that should be called to provide the component and events to update on
---@field args? table arguments to pass to component's callback

---@class section_t
---@field components component_spec[] ordered list of components contained within section
---@field highlight (string|table)? highlight group or attribute table components in section should default to

---@class section_spec
---@field [1] fun(): section_t, events function that should be called to provide the section and events to update on
---@field args? table arguments to pass to section's callback

---@alias bar_spec section_spec[] list of section specs defining bar
---@alias events nil|string|table

---@class config_t
---@field winbar { active: bar_spec?, inactive: bar_spec? }
---@field statusline { active: bar_spec?, inactive: bar_spec?, global: bar_spec? }
---@field tabline { global: bar_spec? }

-- TODO: fix this
---@class cache_t
---@field winbar { active: bar_spec?, inactive: bar_spec? }
---@field statusline { active: bar_spec?, inactive: bar_spec?, global: bar_spec? }
---@field tabline { global: bar_spec? }



-- possibly remove
--[
---@alias component_def { callback: (fun(): component_t), events: string|string[] }
---@alias section_def { callback: (fun(): section_t), events: string|string[] }

---@type table<string, section_def>
local _section_lib = {}

---@type table<string, component_def>
local _component_lib = {}
--]



local bartender = {}


-- TODO
--- Check if bar should be disabled for window
---
---@param win integer? Window handle
local function is_disabled(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  -- disable for popup windows
  if vim.api.nvim_win_get_config(win).zindex ~= nil then
    return true
  end

  -- if vim.bo.buftype == "terminal" then
  --   return true
  -- end
end



--- Holds the currently active window's winid
bartender.active_winid = 1000

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  callback = function()
    bartender.active_winid = vim.api.nvim_get_current_win()
  end
})



--- Set user configurations
---
---@param cfg table Config table
bartender.setup = function(cfg)
  -- set user configuration
  cfg = cfg or {}
  _config = vim.tbl_deep_extend('force', _config, cfg)

  -- set vim options for configured bars
  for _, bar in ipairs(BARS) do
    if _config[bar] ~= nil then
      vim.o[bar] = "%{%v:lua.require('bartender').render('" .. bar .. "')%}"
    end
  end
end


-- TODO
--- Render the string that is used for the bar's option value
---
---@param bar bar_t The bar to render
---@return string The rendered string for the option value
function bartender.render(bar)
  -- determine bar variant
  local variant
  if utils.is_bar_local(bar) then
    variant = (bartender.active_winid == vim.api.nvim_get_current_win()) and "active" or "inactive"
  else
    variant = "global"
  end

  -- render bar string component by component
  local bar_text = {}
  local spec = _config[bar][variant]
  for section_idx, section_spec in ipairs(spec) do
    local section = section_spec[1](section_spec.args)  -- add unpack and/or eval_if_func

    for component_idx, component_spec in ipairs(section.components) do
      local component = component_spec[1](component_spec.args)

      -- handle highlights
      local highlight_name
      if type(component.highlight) == "string" then
        highlight_name = component.highlight
      else
        highlight_name = highlights.get_highlight_name(bar, section_idx, component_idx)
        highlights.create_highlight(highlight_name, component, section)
      end

      -- TODO: handle click events

      table.insert(bar_text, string.format("%%#%s#%s", highlight_name, component.text))
    end
  end
  return table.concat(bar_text)
end

--- Benchmark how long it takes to compute bar
---
---@param bar bar_t
---@param variant variant_t
function bartender.benchmark(bar, variant)
  if not bar or not variant then
    vim.notify("bartender: must pass in a bar and variant to benchmark")
    return
  end
  utils.benchmark("milliseconds", 2, 1e4, function()
    bartender.render(bar)
  end)
end










-- possibly remove
--[
--- Add sections to section_lib
---
---@param name string name of section to add
---@param callback (fun(): section_t) callback function of section
---@param events string|string[] autocmd events to update section on
function bartender.add_section(name, callback, events)
  if _section_lib[name] ~= nil then
    vim.notify("Duplicate section name. Overwriting current entry.")
  end
  _section_lib[name] = {
    callback = callback,
    events = events
  }
end


--- Add components to component_lib
---
---@param name string name of component to add
---@param callback (fun(): component_t) callback function of component
---@param events string|string[] autocmd events to update component on
function bartender.add_component(name, callback, events)
  if _component_lib[name] ~= nil then
    vim.notify("Duplicate component name. Overwriting current entry.")
  end
  _component_lib[name] = {
    callback = callback,
    events = events
  }
end


--- Add sections to section_lib
---
---@param sections table<string, section_def>
function bartender.add_sections(sections)
  _section_lib = vim.tbl_deep_extend("force", _section_lib, sections)
end


--- Add components to component_lib
---
---@param components table<string, section_def>
function bartender.add_components(components)
  _component_lib = vim.tbl_deep_extend("force", _component_lib, components)
end
--]



--- Get the string for the variant of bar
---
---@param bar "winbar"|"statusline"|"tabline"
---@param variant "active"|"inactive"|"global"
bartender.get_bar_string = function(bar, variant)
  local bar_strings = {}
  local winid = vim.api.nvim_get_current_win()
  local cache_bar_table = cache.bars[bar][variant]
  if utils.is_bar_local(bar) then cache_bar_table = cache_bar_table[winid] end
  if cache_bar_table == nil then return "" end

  for section_index, section in ipairs(cache_bar_table) do
    local continuously_upate_section = (section.meta.events == nil)
    if continuously_upate_section then
      section = vim.tbl_deep_extend("force", section, cache.section_lib[section.meta.name].callback(unpack(section.meta.args)))
      for index, component_table in ipairs(section.components) do
        section.components[index] = {
          meta = {
            name = component_table.name,
            args = component_table.args or {}
          }
        }
      end
      cache_bar_table[section_index] = section -- Update cache to point to section
    end
    for component_index, component in ipairs(section.components) do
      -- Handle case when event is nil (update on each statusline refresh)
      local continuously_upate_component = (component.meta.events == nil)
      if continuously_upate_component then
        -- component = cache.component_lib[component.meta.name].callback(unpack(component.meta.args))
        component = vim.tbl_deep_extend("force", component, cache.component_lib[component.meta.name].callback(unpack(component.meta.args)))
        cache_bar_table[section_index].components[component_index] = component -- Update cache to point to component
      end

      local highlight_name
      if type(component.highlight) == "table" then
        highlight_name = highlights.get_highlight_name(bar, section_index, section, component_index, component)
        -- Define highlight if it was never defined or if it does not have a foreground color defined
        -- Second condition is necessary b/c if a change in colorscheme clears a highlight, hlexists still
        -- outputs true if it was defined before, even after it gets cleared
        if vim.fn.hlexists(highlight_name) == 0 or vim.api.nvim_get_hl_by_name(highlight_name, true).foreground == nil then
          highlights.create_highlight(highlight_name, component, section.bg)
        end
      else
        highlight_name = component.highlight
      end

      local highlight_string = (highlight_name == nil) and "" or ("%#"..highlight_name.."#")

      table.insert(bar_strings, highlight_string .. component.text)
    end
  end
  return table.concat(bar_strings)
end



bartender.set_active = function(bar)
  local bar_text = {}

  local bars = {
    winbar = _config.winbar_deprecated,
    statusline = _config.statusline_deprecated,
    tabline = _config.tabline_deprecated,
  }

  if bars[bar] == nil then return end

  local sections = bars[bar]().sections

  for index, section in ipairs(sections) do
    for idx, component in ipairs(section.components) do
      local highlight_name
      if type(component.highlight) == "table" then
        highlight_name = highlights.get_highlight_name(bar, index, section, idx, component)
        if vim.fn.hlexists(highlight_name) == 0 or vim.api.nvim_get_hl_by_name(highlight_name, true).foreground == nil then
          highlights.create_highlight(highlight_name, component, section.bg)
        end
      else
        highlight_name = component.highlight
      end


      table.insert(bar_text, "%#" .. highlight_name .. "#" .. component.text)
    end
  end

  return table.concat(bar_text)
end

bartender.set_inactive = bartender.set_active


-- [[ Autocommands ]


-- -- Set highlights after changing colorschemes
-- vim.api.nvim_create_augroup("BartenderHighlights", {clear = true})
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   group   = "BartenderHighlights",
--   pattern = {'*'},
--   callback = function()
--     for _, bar in ipairs({"winbar", "statusline", "tabline"}) do
--       if config[bar] ~= nil then
--         for _, section in ipairs(config[bar]().sections) do
--           for _, component in ipairs(section.components) do
--             highlights.create_highlight(component, section.bg)
--           end
--         end
--       end
--     end
--   end,
-- })


return bartender
