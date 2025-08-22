return setmetatable({}, {
  __index = function(_, key)
    local statuscolumn_provider_ok, statuscolumn_provider =
      pcall(require, string.format("bartender.providers.statuscolumn.%s", key))
    if not statuscolumn_provider_ok then
      vim.print(statuscolumn_provider)
    else
      return statuscolumn_provider
    end
  end,
})
