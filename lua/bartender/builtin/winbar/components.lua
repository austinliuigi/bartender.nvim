local utils = require("bartender.utils")

local M = {}

-- Shroom icon
M.get_shroom = function()
  return {
    text = "ﳞ",
    highlight = {
      name = "Shroom",
      attributes = {
        fg = utils.get_hl("Function", "foreground"),
      },
    },
  }
end

M.test_lsp = function(client)
  return {
    name = "test_lsp",
    text = client,
    highlight = {
      fg = utils.get_hl("Comment", "foreground")
    }
  }
end

M.get_lsp_symbol = function()
  return {
    name = "LspSymbol",
    text = " ",
    highlight = {
      fg = "#000000"
    }
  }
end

M.get_lsp_separator = function()
  return {
    text = " • ",
    highlight = "Normal"
  }
end

M.get_lsp_clients = function()
  local sections = require("bartender.builtin.winbar.sections")
  local max_chars = ((vim.api.nvim_win_get_width(0)/2)-(require("bartender").get_section_length(sections.center())/2))*3/4
  if max_chars < 0 then max_chars = 0 end

  local symbol, separator = " ", " • "
  local symbol_length, separator_length = vim.fn.strchars(symbol), vim.fn.strchars(separator)
  local client_hl, symbol_hl, separator_hl = "%#Comment#", "%#Type#", "%#Normal#"

  local sum = symbol_length
  local clients = {}
  for idx, client in ipairs(vim.lsp.get_active_clients({bufnr = 0})) do
    sum = sum + #client.name + (idx > 1 and separator_length or 0)
    if sum > max_chars then
      if idx > 1 then
        table.insert(clients, client_hl .. "..")
      end
      break
    end
    table.insert(clients, client_hl .. client.name)
  end

  local text = #clients > 1 and string.format("%s%s", symbol_hl .. symbol, table.concat(clients, separator_hl .. separator)) or ""
  local text_without_highlights = string.gsub(text, "%%%#.-%#", "")

  return {
    text = text,
    length = #text_without_highlights,
    highlight = {
      name = "",
    },
  }
end

M.get_separator = function()
  return {
    name = "Separator",
    text = "%=",
    highlight = "Normal",
  }
end

-- Devicon corresponding to buffer
M.get_devicon = function()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, group = require("nvim-web-devicons").get_icon(filename, fileext, { default = true })

  return {
    name = "Icon",
    text      = icon,
    highlight = {
      devicon = true,
    },
  }
end

-- Tail, relative, or active filepath of buffer
M.get_filepath = function(path_type)
  local filepaths = { tail = "%:t", rel = "%:.", abs = "%:p:~" }
  path_type = path_type or "tail"
  local filepath = vim.fn.expand(filepaths[path_type])
  if filepath == "" then filepath = "???" end

  -- Note: Can't use length of components because navic uses length of this (loop)
  local truncate_width = vim.api.nvim_win_get_width(0)/3
  local truncate_length = 5
  while #vim.fn.expand(filepath) > truncate_width and truncate_length >= 1 do
    filepath = vim.fn.pathshorten(filepath, truncate_length)
    truncate_length = truncate_length - 1
  end

  return {
    name = "Filepath",
    text      = filepath,
    highlight = {
      fg = utils.get_hl("Normal", "foreground"),
    },
  }
end

-- Readonly indicator
M.get_readonly = function()
  return {
    name = "Readonly",
    text      = vim.o.readonly and " " or "",
    highlight = {
      fg = "lightblue",
    },
  }
end

-- Modified indicator
M.get_modified = function()
  return {
    name = "Modified",
    text      = vim.o.modified and " ●" or "",
    highlight = {
      fg = "lightpink",
    },
  }
end

-- Treesitter code context
M.get_navic = function()
  local sections = require("bartender.builtin.winbar.sections")
  local max_chars = ((vim.api.nvim_win_get_width(0)/2)-(require("bartender").get_section_length(sections.center())/2))*3/4
  if max_chars < 0 then max_chars = 0 end

  local code_context = require("nvim-navic").get_location()                  -- Note: includes statusline/winbar highlighting
  local code_context_underwear = string.gsub(code_context, "%%%#.-%#", "")   -- Remove any highlight codes (e.g. %#Group#)
  local code_context_naked = string.gsub(code_context_underwear, "%%%*", "") -- Remove any default highlight codes (%*)

  local ellipsis = "%#NavicText#.."
  while vim.fn.strchars(code_context_naked) > max_chars do
    local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
    code_context_underwear = string.gsub(code_context, "%%%#.-%#", "")
    code_context_naked = string.gsub(code_context_underwear, "%%%*", "")
  end

  return {
    text      = code_context,
    length    = vim.fn.strchars(code_context_naked),
    highlight = ""
  }
end

-- Space character for separating center components
M.get_center_space = function()
  return {
    name = "CenterSpace",
    text      = " ",
    highlight = {
    }
  }
end



--[[ Edges ]]

-- Left edge/border of center components
M.get_centerside_left_edge = function()
  return {
    name = "CentersideLeftEdge",
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

-- Right edge/border of center components
M.get_centerside_right_edge = function()
  return {
    name = "CentersideRightEdge",
    text      = "",
    highlight = {
      reverse = true,
    },
  }
end



--[[ Padding ]]

-- Padding between left screen edge and leftmost component
M.get_left_padding = function()
  return {
    name = "LeftPadding",
    text = " ",
    highlight = "Normal",
  }
end

-- Padding between right screen edge and rightmost component
M.get_right_padding = function()
  return {
    name = "RightPadding",
    text = " ",
    highlight = "Normal",
  }
end

-- Padding to keep the center components static
M.get_left_center_padding = function()
  local bartender = require("bartender")
  local sections = require("bartender.builtin.winbar.sections")
  local diff = 0
  if bartender.get_section_length(sections.left()) < bartender.get_section_length(sections.right()) then
    diff = bartender.get_section_length(sections.right()) - bartender.get_section_length(sections.left())
  end

  return {
    text = string.rep(" ", diff),
    highlight = "Normal",
  }
end

-- Padding to keep the center components static
M.get_right_center_padding = function()
  local bartender = require("bartender")
  local sections = require("bartender.builtin.winbar.sections")
  local diff = 0
  if bartender.get_section_length(sections.left()) > bartender.get_section_length(sections.right()) then
    diff = bartender.get_section_length(sections.left()) - bartender.get_section_length(sections.right())
  end
  return {
    text = string.rep(" ", diff),
    highlight = "Normal",
  }
end

return M
