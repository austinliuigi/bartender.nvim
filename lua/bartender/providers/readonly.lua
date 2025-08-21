--- Icon showing if current buffer is readonly

---@param icon? string Icon to show when current buffer is readonly
return function(icon)
  icon = icon or ""
  return {
    vim.o.readonly and icon or "",
    hl = {
      fg = require("bartender.utils").hl_attr_wrap("WarningMsg", "fg"),
    },
  }, { { "OptionSet", "readonly" } }
end
