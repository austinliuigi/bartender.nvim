local components = require("bartender.builtin.components")
local utils = require("bartender.utils")

return function(fg, bg)
  fg = fg or utils.hl_attr_wrap("Normal", "fg")
  bg = bg or utils.hl_attr_wrap("Comment", "fg")

  return {
    { " ", hl = { bg = bg } },
    { components.lsp_root, hl = { fg = fg, bg = bg } },
    { "", hl = { fg = bg } },
  }, {}
end
