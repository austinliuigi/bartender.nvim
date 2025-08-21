local providers = require("bartender.providers")

return function()
  return {
    { " ", hl = providers.mode.current_mode_hl },
    { providers.mode },
    { " ", hl = providers.mode.current_mode_hl },
  }, {}
end
