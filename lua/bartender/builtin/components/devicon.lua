local utils = require("bartender.utils")
local nvim_web_devicons_ok, nvim_web_devicons = pcall(require, "nvim-web-devicons")
if not nvim_web_devicons_ok then
  vim.notify("bartender: unable to load nvim-web-devicons", vim.log.levels.ERROR)
  return nil
end
local devicon = {}


--- Devicons corresponding to the buffer's file
--
function devicon.provider()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, color = nvim_web_devicons.get_icon(filename, fileext, { default = true })

  return {
    text = icon,
    highlight = {
      fg = utils.get_hl_attr(color, "fg"),
    },
  }, { "BufEnter" }
end


return devicon
