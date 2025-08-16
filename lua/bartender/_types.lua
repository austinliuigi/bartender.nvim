---@alias bar_t "winbar"|"statusline"|"tabline"
---@alias variant_t "active"|"inactive"|"global"
---@alias events nil|string|table

-- COMPONENTS
----------------------------------------------------
---
---@class component_t
---@field text string text that should be shown on bar
---@field highlight (string|table)? highlight group or attribute table component should take on
---@field click function?

---@alias component_provider fun(): component_t, events function that provides the components and events to update on

---@class component_spec
---@field [1]? string|component_provider if string then text that is displayed elseif nil then skip component else component provider
---@field args? table|fun(): table arguments to pass to component's callback
---@field highlight? string|table highlight group or attribute table component should take on; this takes precedence over the highlights in provider

-- SECTIONS
----------------------------------------------------
---@class section_t
---@field components component_spec[] ordered list of components contained within section

---@alias section_provider fun(): section_t, events function that provides the sections and events to update on

---@class section_spec
---@field [1] section_provider section provider
---@field args? table|fun(): table arguments to pass to section's callback

-- BARS
----------------------------------------------------
---@alias bar_spec section_spec[] list of section specs defining bar

---@class config_t
---@field winbar { active: bar_spec?, inactive: bar_spec? }
---@field statusline { active: bar_spec?, inactive: bar_spec?, global: bar_spec? }
---@field tabline { global: bar_spec? }
---@field statuscolumn { active: bar_spec?, inactive: bar_spec? }

-- CACHE
----------------------------------------------------
-- TODO: fix this
---@class cache_t
---@field winbar { active: bar_spec?, inactive: bar_spec? }
---@field statusline { active: bar_spec?, inactive: bar_spec?, global: bar_spec? }
---@field tabline { global: bar_spec? }
