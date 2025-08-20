--- Icon icon representing current buffer's fileformat

local formats = {
  dos = "",
  unix = "",
  mac = "",
}

return function()
  local icon = formats[vim.o.fileformat] or ""
  return {
    icon,
  }, { { "OptionSet", "fileformat" } }
end
