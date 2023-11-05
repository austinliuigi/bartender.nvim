local utils = require("bartender.utils")
local modified = {}


--- Icon showing if current buffer is has been modified
--
---@param lsep? string optional left separator
---@param rsep? string optional right separator
function modified.provider(lsep, rsep)
  lsep = lsep or ""
  rsep = rsep or ""

  local icon = lsep.."●"..rsep
  return {
    text = vim.o.modified and icon or "",
    highlight = {
      fg = utils.get_hl_attr("ErrorMsg", "fg"),
    },
  }
end


return modified
