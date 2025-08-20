local components = require("bartender.builtin.components")
local utils = require("bartender.utils")

return function(fg, bg)
  fg = fg or "transparent"
  bg = bg or utils.hl_attr_wrap("Comment", "fg")

  return {
    { "", hl = { fg = "transparent", bg = bg } },
    { " ", hl = { bg = bg } },
    { components.bufnr, hl = { fg = fg, bg = bg, bold = true } },
    { " ", hl = { bg = bg } },
  }, {}
end
