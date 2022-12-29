local winbar_sections = require("bartender.builtin.winbar.sections")

local config = {
    filepath_type = "tail", -- "tail" | "rel" | "abs"
    highlight_prefix = "WinBar",

    winbar = function()
      return {
        highlight_prefix = "WinBar",
        sections = {
          winbar_sections.left(),
          winbar_sections.left_center_padding(),
          winbar_sections.center(),
          winbar_sections.right_center_padding(),
          winbar_sections.right(),
        },
      }
    end
}

return config
