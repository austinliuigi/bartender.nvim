local providers = require("bartender.providers")

return function()
  return {
    { "" },
    { " " },
    { providers.cwd },
  }, {}
end
