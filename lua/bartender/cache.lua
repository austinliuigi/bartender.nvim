local M = {}

--- Cache holds all static components, and dynamic components that don't update on every redraw
---   - component groups can't be cached because it may have children that need to be updated
---@type bartender.Cache
M.cache = {}

-- Remove entry from cache and all associated state
--   - if entry is a dynamic component, remove its evaluated component
--   - if entry is a component group, remove any descendants
--   - clear highlight
--   - clear autocmds
--   - clear click
---@param component_name string
---@param dont_recurse? boolean
M.remove = function(component_name, dont_recurse)
  local cache_entry = M.cache[component_name]
  if cache_entry == nil then
    return
  end

  if not dont_recurse then
    if cache_entry.evaled_component_name then
      M.remove(cache_entry.evaled_component_name)
    end

    if cache_entry.children then
      for _, child_name in ipairs(cache_entry.children) do
        M.remove(child_name)
      end
    end
  end

  -- clear highlight group
  if cache_entry.hl_group then
    vim.cmd("hi clear " .. cache_entry.hl_group)
  end

  -- clear any autocommands
  if cache_entry.augroup_id then
    vim.api.nvim_del_augroup_by_id(cache_entry.augroup_id)
  end

  M.cache[component_name] = nil
end

--- Clear matching entries from the cache. If pattern is not provided, clear all entries from the cache.
---
---@param pattern? string
M.clear = function(pattern)
  for component_name, _ in pairs(M.cache) do
    if not pattern or component_name:match(pattern) then
      M.remove(component_name, true)
    end
  end
end

--- Clear cache of any local bars when changing windows
---   - necessary to prevent any stale components that are present before focus changed
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  callback = function()
    M.clear("W%d+")
  end,
})

--- Clear cache after colorscheme changes to ensure updated reference colors are used
--
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  callback = function()
    M.clear()
  end,
})

return M
