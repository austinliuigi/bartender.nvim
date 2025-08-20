--- Devicons corresponding to the buffer's file
---   - requires nvim-web-devicons to be installed

local nvim_web_devicons_ok, nvim_web_devicons = pcall(require, "nvim-web-devicons")
if not nvim_web_devicons_ok then
  vim.notify("bartender: unable to load nvim-web-devicons", vim.log.levels.ERROR)
  return nil
end

return function()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, icon_hl_group = nvim_web_devicons.get_icon(filename, fileext, { default = true })

  return {
    icon,
    hl = {
      fg = require("bartender.utils").hl_attr(icon_hl_group, "fg"),
    },
  }, { "BufEnter" }
end
