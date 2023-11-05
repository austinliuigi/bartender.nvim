local components = require("bartender.builtin.components")
local navic = {}

--- Effective current working directory
--
function navic.provider()
  return {
    components = {
      { components.navic },
      { " " },
    },
  }
end


return navic
