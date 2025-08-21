---@alias bartender.Bar "winbar"|"statusline"|"tabline"
---@alias bartender.BarVariant "active"|"inactive"|"global"

---@alias bartender.Highlight string|table|fun(): string|table
---@alias bartender.Events string|(string|(string|string[])[])[] Examples: "BufWrite" | {"BufWrite", "BufRead"} | { "BufWrite", { "OptionSet", "fileformat" } | { "OptionSet", { "readonly", "modified" } } }

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
---@class bartender.CachedStaticComponent
---@field str string
---@field hl_group? string
---@field click_fn? function

---@class bartender.CachedDynamicComponent
---@field evaled_component bartender.Component
---@field evaled_component_name string
---@field augroup_id? integer
---@field update_on_redraw? boolean

---@class bartender.CachedComponentGroup
---@field children string[]

---@alias bartender.CachedComponent bartender.CachedStaticComponent|bartender.CachedDynamicComponent|bartender.CachedComponentGroup
---@alias bartender.Cache { [string]: bartender.CachedComponent }
