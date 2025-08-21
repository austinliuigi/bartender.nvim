local utils = require("bartender.utils")

return function(fg, bg)
  fg = fg or utils.hl_attr_wrap("Normal", "bg")
  bg = bg or utils.hl_attr_wrap("Comment", "fg")

  return {
    { "", hl = { fg = bg } },
    { " ", hl = { bg = bg } },
    { "%l", hl = { fg = fg, bg = bg } },
    { ":", hl = { fg = fg, bg = bg } },
    { "%v", hl = { fg = fg, bg = bg } },
    { " ", hl = { bg = bg } },
    { "", hl = { fg = bg } },
  }, {}
end
