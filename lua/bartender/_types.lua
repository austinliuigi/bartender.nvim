---@alias bartender.Bar "winbar"|"statusline"|"tabline"
---@alias bartender.BarVariant "active"|"inactive"|"global"

---@alias bartender.Highlight string|table|fun(): string|table
---@alias bartender.Events string|(string|string[])[] Examples: "BufWrite" | {"BufWrite", "BufRead"} | { "BufWrite", { "OptionSet", "fileformat" } }

-- COMPONENTS
----------------------------------------------------
---@class bartender.StaticComponent
---@field [1] string Text to display on bar
---@field hl? bartender.Highlight Highlight group or attribute table for component
---@field on_click? function Click handler for component

---@class bartender.DynamicComponent
---@field [1] bartender.DynamicComponentProvider Component provider
---@field args? any|fun(): any[] Arguments to pass to component provider
---@field hl? bartender.Highlight Override highlights to use instead of provider's
---@field on_click? bartender.Highlight Override click handler to use instead of provider's

---@alias bartender.DynamicComponentProvider fun(): bartender.Component, bartender.Events? Function that provides the components and events to update on

---@class bartender.ComponentGroup
---@field [integer] bartender.Component
---@field on_click? function Click handler to use for all components in the group

---@alias bartender.Component bartender.StaticComponent|bartender.DynamicComponent|bartender.ComponentGroup

-- BARS
----------------------------------------------------
---@class bartender.Config
---@field winbar { active: bartender.ComponentGroup?, inactive: bartender.ComponentGroup? , disable: fun(): boolean}
---@field statusline { active: bartender.ComponentGroup?, inactive: bartender.ComponentGroup?, global: bartender.ComponentGroup?, disable: fun(): boolean }
---@field tabline { global: bartender.ComponentGroup?, disable: fun(): boolean }
---@field statuscolumn { active: bartender.ComponentGroup?, inactive: bartender.ComponentGroup?, disable: fun(): boolean }

-- CACHE
----------------------------------------------------
-- TODO: fix this
-- Cache only contains cached components
-- How to create identifier?
--  - can't use flat component index, because if a component group before the current updates and changes the number of components, it chances the index of our current component
--  - ues combination of componentgroup index and component index

---@alias bartender.BarCacheComponent { str: string, hl_group: string, click_fn: function, autocmd_id: integer}
---@alias bartender.BarCache { [string]: bartender.BarCacheComponent }

---@class bartender.Cache
---@field winbar { active: bartender.BarCache?, inactive: bartender.BarCache? }
---@field statusline { active: bartender.BarCache?, inactive: bartender.BarCache?, global: bartender.BarCache? }
---@field tabline { global: bartender.BarCache? }
