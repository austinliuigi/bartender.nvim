local highlights = require("bartender.highlights")
local config = require("bartender.config")

local bartender = {}

bartender.setup = function(cfg)
  for key, value in pairs(cfg) do
    config[key] = value
  end
end

bartender.get_section_length = function(section)
  local sum = 0
  for _, component in ipairs(section.components) do
    local component_length = component.length or vim.fn.strchars(component.text)
    sum = sum + component_length
  end
  return sum
end

function benchmark(unit, decPlaces, n, f, ...)
  local units = {
    ['seconds'] = 1,
    ['milliseconds'] = 1000,
    ['microseconds'] = 1000000,
    ['nanoseconds'] = 1000000000
  }
  local elapsed = 0
  local multiplier = units[unit]
  for i = 1, n do
    local now = os.clock()
    f(...)
    elapsed = elapsed + (os.clock() - now)
  end
  print(string.format('Benchmark results:\n  - %d function calls\n  - %.'.. decPlaces ..'f %s elapsed\n  - %.'.. decPlaces ..'f %s avg execution time.', n, elapsed * multiplier, unit, (elapsed / n) * multiplier, unit))
end

bartender.benchmark = function(bar)
  benchmark("milliseconds", 2, 1000, function()
    bartender.set_active(bar)
  end)
end



--[[ Set winbar options ]]

-- Return winbar expression for active winbar
bartender.set_active = function(bar)
  local bar_text = {}

  local bars = {
    winbar = config.winbar,
    statusline = config.statusline,
    tabline = config.tabline,
  }

  local sections = bars[bar]().sections

  for index, section in ipairs(sections) do
    for _, component in ipairs(section.components) do
      table.insert(bar_text, "%#" .. highlights.get_highlight(component) .. "#" .. component.text)
    end
    -- Insert separator after first and before last sections
    local separator_locations = { [1] = true, [#sections-1] = true }
    if separator_locations[index] ~= nil then
      table.insert(bar_text, "%=")
    end
  end

  return table.concat(bar_text)
end

-- Return winbar expression for inactive winbar
bartender.set_inactive = function(bar)
  local bar_text = {}

  local sections = config.winbar().sections

  for index, section in ipairs(sections) do
    for _, component in ipairs(section.components) do
      table.insert(bar_text, "%#" .. highlights.get_highlight(component) .. "#" .. component.text)
    end
    -- Insert separator after first and before last sections
    local separator_locations = { [1] = true, [#sections-1] = true }
    if separator_locations[index] ~= nil then
      table.insert(bar_text, "%=")
    end
  end

  return table.concat(bar_text)
end



-- [[ Autocommands ]

if config.winbar ~= nil then
  -- Set winbar options
  vim.api.nvim_create_augroup("Bartender", {clear = true})
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group   = "Bartender",
    pattern = {'*'},
    callback = function()
      if vim.api.nvim_win_get_config(0).zindex ~= nil then
        vim.wo.winbar = ""
      else
        vim.wo.winbar = "%{%v:lua.require('bartender').set_active('winbar')%}"
      end
    end
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group   = "Bartender",
    pattern = {'*'},
    callback = function()
      if vim.api.nvim_win_get_config(0).zindex ~= nil then
        vim.wo.winbar = ""
      else
        vim.wo.winbar = "%{%v:lua.require('bartender').set_inactive('winbar')%}"
      end
    end
  })
end

if config.statusline ~= nil then
  -- Set winbar options
  vim.api.nvim_create_augroup("Bartender", {clear = true})
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group   = "Bartender",
    pattern = {'*'},
    callback = function()
      if vim.api.nvim_win_get_config(0).zindex ~= nil then
        vim.wo.statusline = ""
      else
        vim.wo.statusline = "%{%v:lua.require('bartender').set_active('statusline')%}"
      end
    end
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group   = "Bartender",
    pattern = {'*'},
    callback = function()
      if vim.api.nvim_win_get_config(0).zindex ~= nil then
        vim.wo.statusline = ""
      else
        vim.wo.statusline = "%{%v:lua.require('bartender').set_inactive('statusline')%}"
      end
    end
  })
end

if config.tabline ~= nil then
  vim.o.tabline = "%{%v:lua.require('bartender').set_active('tabline')%}"
end

-- Set highlights after changing colorschemes
vim.api.nvim_create_augroup("BartenderHighlights", {clear = true})
vim.api.nvim_create_autocmd("ColorScheme", {
  group   = "BartenderHighlights",
  pattern = {'*'},
  callback = function()
    for _, bar in ipairs({"winbar", --[[ "statusline", ]] "tabline"}) do
      for _, section in ipairs(config[bar]().sections) do
        highlights.create_highlights(section.components, section.bg)
      end
    end
  end,
})

return bartender
