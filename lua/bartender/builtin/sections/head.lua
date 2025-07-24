local components = require("bartender.builtin.components")
local head = {}

--- Head of bar
--
function head.provider(fg, bg)
  return {
    components = {
      { "█", highlight = { fg = bg } },
      { components.lsp_root, highlight = { fg = fg, bg = bg } },
      { "", highlight = { fg = bg } },
      { " " },
    },
  }
end

return head
