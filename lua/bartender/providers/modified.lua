--- Icon showing if current buffer is has been modified

---@param icon? string Icon to show when current buffer is modified
return function(icon)
  icon = icon or "●"
  return {
    vim.o.modified and icon or "",
    hl = {
      fg = require("bartender.utils").hl_attr_wrap("ErrorMsg", "fg"),
    },
  }, { "BufModifiedSet" }
end
