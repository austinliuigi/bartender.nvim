local utils = require("bartender.utils")
local components = require("bartender.builtin.components")
local cwd = {}


--- Effective current working directory
--
function cwd.provider()
  return {
    components = {
      { "" },
      { " "},
      { components.cwd },
    }
  }
end


return cwd
