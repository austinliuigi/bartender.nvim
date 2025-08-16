local BARS = { "winbar", "statusline", "tabline", "statuscolumn" }
local VARIANTS = { "active", "inactive", "global" }

local M = {}

-- TODO
--- Check if bar should be disabled for window
---
---@param win integer? Window handle
local function is_disabled(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  -- disable for popup windows
  if vim.api.nvim_win_get_config(win).zindex ~= nil then
    return true
  end

  -- if vim.bo.buftype == "terminal" then
  --   return true
  -- end
end

-- keep track of the active window's id
M.active_winid = nil
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  callback = function()
    M.active_winid = vim.api.nvim_get_current_win()
  end,
})

--- Set user configurations
---
---@param cfg table Config table
---@param base? "default"|"current"|"none"
M.setup = function(cfg, base)
  -- set user configuration
  local config = require("bartender.config")
  config.configure(cfg, base)

  -- set vim options for configured bars
  for _, bar in ipairs(BARS) do
    if config[bar] ~= nil then
      vim.o[bar] = "%{%v:lua.require('bartender.render').render('" .. bar .. "')%}"
    end
  end
end

return M
