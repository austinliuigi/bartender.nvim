local utils = require("bartender.utils")
local fileformat = {}


local formats = {
  dos = "",
  unix = "",
  mac = "",
}

--- Icon showing if current buffer is has been fileformat
--
function fileformat.provider()
  local icon = formats[vim.o.fileformat]
  return {
    text = icon,
  }
end


return fileformat
