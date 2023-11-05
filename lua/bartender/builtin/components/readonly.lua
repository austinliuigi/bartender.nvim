local utils = require("bartender.utils")
local readonly = {}


--- Icon showing if current buffer is has been modified
--
---@param lsep? string optional left separator
---@param rsep? string optional right separator
function readonly.provider(lsep, rsep)
  lsep = lsep or ""
  rsep = rsep or ""

  local icon = lsep..""..rsep
  return {
    text = vim.o.readonly and icon or "",
    highlight = {
      fg = utils.get_hl_attr("WarningMsg", "fg"),
    },
  }
end


return readonly
