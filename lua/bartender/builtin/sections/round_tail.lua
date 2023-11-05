local components = require("bartender.builtin.components")
local tail = {}

--- Round tail of bar
--
function tail.provider(fg, bg)
  return {
    components = {
      { "", highlight = { fg = fg, bg = bg, reverse = true } },
      { "█", highlight = { fg = fg } },
      { components.fileformat, highlight = { fg = fg, reverse = true } },
      { "█", highlight = { fg = fg } },
    }
  }
end


return tail
