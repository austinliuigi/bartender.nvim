local components = require("bartender.builtin.components")
local head = {}

--- Head of bar
--
function head.provider(color)
  return {
    components = {
      { "█", highlight = { fg = color } },
      { components.lsp_root, highlight = { fg = color, reverse = true } },
      { "", highlight = { fg = color } },
      { " " },
    }
  }
end


return head
