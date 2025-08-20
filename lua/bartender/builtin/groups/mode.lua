local components = require("bartender.builtin.components")

return {
  { " ", hl = components.mode.current_mode_hl },
  { components.mode },
  { " ", hl = components.mode.current_mode_hl },
}
