local components = require("bartender.builtin.components")

return function()
  return {
    { "" },
    { " " },
    { components.cwd },
  }, {}
end
