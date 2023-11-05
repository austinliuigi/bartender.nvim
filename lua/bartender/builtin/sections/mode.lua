local utils = require("bartender.utils")
local components = require("bartender.builtin.components")
local mode_component = require("bartender.builtin.components.mode")
local mode = {}

--- Current (neo)vim mode
--
function mode.provider()
  local mode_component_hl_reverse = mode_component.get_current_mode_highlight_reversed()
  return {
    components = {
      -- { "░▒▓█", highlight = mode_component_hl_reverse },
      { "█", highlight = mode_component_hl_reverse },
      { components.mode },
      { "█", highlight = mode_component_hl_reverse },
      -- { "█▓▒░", highlight = mode_component_hl_reverse },
    },
  }
end


return mode
