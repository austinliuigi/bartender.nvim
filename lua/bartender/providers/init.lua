return setmetatable({}, {
  __index = function(_, key)
    local provider_ok, provider = pcall(require, string.format("bartender.providers.%s", key))
    if not provider_ok then
      vim.print(provider)
    else
      return provider
    end
  end,
})
