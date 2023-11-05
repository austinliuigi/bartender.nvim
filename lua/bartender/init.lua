------- Type Definitions -------

---@alias bar_t "winbar"|"statusline"|"tabline"
---@alias variant_t "active"|"inactive"|"global"
local BARS = { "winbar", "statusline", "tabline", }
local VARIANTS = { "active", "inactive", "global" }

---@class component_t
---@field text string text that should be shown on bar
---@field highlight (string|table)? highlight group or attribute table component should take on
---@field click function?

---@alias component_provider fun(): component_t, events function that provides the components and events to update on

---@class component_spec
---@field [1]? string|component_provider if string then text that is displayed elseif nil then skip component else component provider
---@field args? table|fun(): table arguments to pass to component's callback
---@field highlight? string|table highlight group or attribute table component should take on; this takes precedence over the highlights in provider


---@class section_t
---@field components component_spec[] ordered list of components contained within section

---@alias section_provider fun(): section_t, events function that provides the sections and events to update on

---@class section_spec
---@field [1] section_provider section provider
---@field args? table|fun(): table arguments to pass to section's callback


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


------- Bartender Interface and Implementation -------

local utils = require("bartender.utils")
local highlights = require("bartender.utils.highlights")
local _config = require("bartender.config")
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


--- Render the string that is used for a component's highlight
--
---@param bar_str string Component's rendered bar string without highlights applied
---@param highlight_group string Name of the highlight group
---@return string wrapped_bar_string Bar string wrapped with highlight formatting
function bartender._apply_highlight(bar_str, highlight_group)
  if highlight_group == nil then
    return bar_str
  end
  return "%#"..highlight_group.."#"..bar_str.."%*"
end


--- Render the string that is used for the bar's option value
---
---@param bar bar_t The bar to render
---@return string bar_string The rendered string for the option value
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
    local section = section_spec[1](unpack(utils.eval_if_func(utils.replace_nil(section_spec.args))))

    for component_idx, component_spec in ipairs(section.components) do
      -- parse component_spec to get component
      local component
      if type(component_spec[1]) == "string" then
        component = {
          text = component_spec[1],
        }
      elseif type(component_spec[1]) == "function" then
        component = component_spec[1](unpack(utils.eval_if_func(utils.replace_nil(component_spec.args))))
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
          utils.replace_nil(component.highlight),
          utils.replace_nil(component_spec.highlight)
        )
      end

      -- TODO: handle click events

      local component_str = component.text
      component_str = bartender._apply_highlight(component_str, highlight_group)
      table.insert(bar_text, component_str)

      ::continue::
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


return bartender
