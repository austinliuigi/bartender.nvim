local components = require("bartender.components")
local highlights = require("bartender.highlights")
local config = require("bartender.config")

local bartender = {}

bartender.toggle_filepath_type = function()
  local next_type = {
    tail = "rel",
    rel = "abs",
    abs = "tail",
  }
  config.filepath_type = next_type[config.filepath_type]
end

bartender.left_components = function()
  return {
    components.get_left_padding(),
    components.get_lsp_symbol(),
    components.get_lsp_clients(),
  }
end

bartender.left_center_padding = function()
  return {
    components.get_left_center_padding(),
  }
end

bartender.center_components = function()
  return {
    components.get_centerside_left_edge(),
    components.get_devicon(),
    components.get_center_space(),
    components.get_filepath(),
    components.get_readonly(),
    components.get_modified(),
    components.get_centerside_right_edge(),
  }
end

bartender.right_center_padding = function()
  return {
    components.get_right_center_padding(),
  }
end

bartender.right_components = function()
  return {
    components.get_navic(),
    components.get_right_padding(),
  }
end

-- Length of left components (used to calculate right_center_padding)
bartender.left_length = function()
  local sum = 0
  for _, component in ipairs(bartender.left_components()) do
    local component_length = component.length or vim.fn.strchars(component.text)
    sum = sum + component_length
  end
  return sum
end

-- Length of center components (used to calculate navic length)
bartender.center_length = function()
  local sum = 0
  for _, component in ipairs(bartender.center_components()) do
    local component_length = component.length or vim.fn.strchars(component.text)
    sum = sum + component_length
  end
  return sum
end

-- Length of right components (used to calculate left_center_padding)
bartender.right_length = function()
  local sum = 0
  for _, component in ipairs(bartender.right_components()) do
    local component_length = component.length or vim.fn.strchars(component.text)
    sum = sum + component_length
  end
  return sum
end



--[[ Set winbar options ]]

-- Return winbar expression for active winbar
bartender.set_active = function()
  local bar_text = {}

  local sections = {
    bartender.left_components(),
    bartender.left_center_padding(),
    bartender.center_components(),
    bartender.right_center_padding(),
    bartender.right_components()
  }
  for index, section in ipairs(sections) do
    for _, component in ipairs(section) do
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
bartender.set_inactive = function()
  local bar_text = {}

  local sections = {
    bartender.left_components(),
    bartender.left_center_padding(),
    bartender.center_components(),
    bartender.right_center_padding(),
    bartender.right_components()
  }
  for index, section in ipairs(sections) do
    for _, component in ipairs(section) do
      table.insert(bar_text, "%#" .. config.highlight_prefix .. component.highlight.name .. "#" .. component.text)
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

-- Set winbar options
vim.api.nvim_create_augroup("Bartender", {clear = true})
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group   = "Bartender",
  pattern = {'*'},
  callback = function()
    if vim.api.nvim_win_get_config(0).zindex ~= nil then
      vim.wo.winbar = ""
    else
      vim.wo.winbar = "%{%v:lua.require('bartender').set_active()%}"
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
      vim.wo.winbar = "%{%v:lua.require('bartender').set_inactive()%}"
    end
  end
})

-- Set winbar highlights after changing colorschemes
vim.api.nvim_create_augroup("BartenderHighlights", {clear = true})
vim.api.nvim_create_autocmd("ColorScheme", {
  group   = "BartenderHighlights",
  pattern = {'*'},
  callback = function()
    highlights.set_highlights(bartender.left_components(), highlights.colors().left_bg)
    highlights.set_highlights(bartender.center_components(), highlights.colors().center_bg)
    highlights.set_highlights(bartender.right_components(), highlights.colors().right_bg)
  end,
})

return bartender
