local M = {}

M.click_fns = {}

M.register = function(component_name, click_fn)
  M.click_fns[component_name] = click_fn
end

M.deregister = function(component_name)
  for name, click_fn in pairs(M.click_fns) do
    if string.match(name, component_name) then
      M.click_fns[name] = nil
    end
  end
end

--- Get the click function for a component
---
---@param component_name string
---@param click_fn function
---@return string click_str
M.get = function(component_name, click_fn)
  M.register(component_name, click_fn)
  return string.format("v:lua.require'bartender.click'.click_fns.%s", component_name)
end

return M
