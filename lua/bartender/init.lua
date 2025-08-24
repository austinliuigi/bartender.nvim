local BARS = { "winbar", "statusline", "tabline", "statuscolumn" }
local VARIANTS = { "active", "inactive", "global" }

local M = {}

-- Sections and components are evaluated in the context of the window that the bar belongs to at the time of evaluation. Keep track of the active window's id in a global
M.active_winid = nil
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  callback = function()
    M.active_winid = vim.api.nvim_get_current_win()
  end,
})

-- Set up bars whenever options determining locality of bars change
vim.api.nvim_create_augroup("BartenderReload", { clear = true })
vim.api.nvim_create_autocmd("OptionSet", {
  group = "BartenderReload",
  pattern = { "laststatus", "showtabline" },
  callback = function()
    require("bartender").setup()
  end,
})

--- Set user configurations
---
---@param cfg table
---@param base? "default"|"current"|"none" Whether to merge config or override
M.setup = function(cfg, base)
  -- set user configuration
  local config = require("bartender.config")
  config.configure(cfg, base)

  -- clear cache if it was previously filled
  require("bartender.cache").clear()

  -- set vim options for configured bars
  for _, bar in ipairs(BARS) do
    local configure_bar = false
    local is_bar_local = require("bartender.utils").is_bar_local(bar)
    if config[bar] ~= nil then
      if is_bar_local and config[bar].active ~= nil and config[bar].inactive ~= nil then
        configure_bar = true
      elseif not is_bar_local and config[bar].global ~= nil then
        configure_bar = true
      end
    end

    if configure_bar then
      vim.o[bar] = "%{%v:lua.require('bartender.resolve').resolve_bar('" .. bar .. "')%}"
      if bar == "statuscolumn" then
        vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
          callback = function()
            vim.o[bar] = "%{%v:lua.require('bartender.resolve').resolve_bar('" .. bar .. "')%}"
          end,
          desc = "Re-set statuscolumn when changing windows so width of the evaluated format string is not preserved",
        })
      end
    else
      vim.o[bar] = nil
    end
  end
end

return M
