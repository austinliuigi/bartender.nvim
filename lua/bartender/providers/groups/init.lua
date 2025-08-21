return setmetatable({}, {
  __index = function(_, key)
    local group_provider_ok, group_provider = pcall(require, string.format("bartender.providers.groups.%s", key))
    if not group_provider_ok then
      vim.print(group_provider)
    else
      return group_provider
    end
  end,
})
