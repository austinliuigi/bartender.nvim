local components = require("bartender.builtin.components")
local file = {}

--- Info about buffer's file (devicon, filepath, modified status, readonly)
--
function file.provider()
  return {
    components = {
      { components.devicon },
      { " " },
      { components.filepath, args = {0, ":~:."} },
      { components.modified, args = {" "} },
      { components.readonly, args = {" "} },
    }
  }
end


return file
