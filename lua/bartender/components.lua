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

M.get_lsp_symbol = function()
  return {
    text = #vim.lsp.get_active_clients({bufnr = 0}) == 0 and "" or  " ",
    highlight = {
      name = "Special",
    },
  }
end

M.get_lsp_clients = function()
  local clients = {}
  for _, client in ipairs(vim.lsp.get_active_clients({bufnr = 0})) do
    table.insert(clients, client.name)
  end
  local text = table.concat(clients, " • ")

  return {
    text = text,
    highlight = {
      name = "Lsp",
      attributes = {
        fg = utils.get_hl("Comment", "foreground"),
        bold = true,
        italic = false,
      }
    },
  }
end

-- Devicon corresponding to buffer
M.get_devicon = function()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, group = require("nvim-web-devicons").get_icon(filename, fileext, { default = true })

  return {
    text      = icon,
    highlight = {
      name = group,
      devicon = true,
    },
  }
end

-- Tail, relative, or active filepath of buffer
M.get_filepath = function()
  local filepaths = { tail = "%:t", rel = "%:.", abs = "%:p:~" }
  local filepath = vim.fn.expand(filepaths[require("bartender.config").filepath_type])
  filepath = filepath == "" and "???" or filepath

  -- Note: Can't use length of components because navic uses length of this (loop)
  local truncate_width = vim.api.nvim_win_get_width(0)/3
  local truncate_length = 5
  while #vim.fn.expand(filepath) > truncate_width and truncate_length >= 1 do
    filepath = vim.fn.pathshorten(filepath, truncate_length)
    truncate_length = truncate_length - 1
  end

  return {
    text      = filepath,
    highlight = {
      name = "Filepath",
      attributes = {
        fg = utils.get_hl("Normal", "foreground"),
      },
    },
  }
end

-- Readonly indicator
M.get_readonly = function()
  return {
    text      = vim.o.readonly and " " or "",
    highlight = {
      name = "Readonly",
      attributes = {
        fg = "lightblue",
      }
    },
  }
end

-- Modified indicator
M.get_modified = function()
  return {
    text      = vim.o.modified and " ●" or "",
    highlight = {
      name = "Modified",
      attributes = {
        fg = "lightpink",
      },
    },
  }
end

-- Treesitter code context
M.get_navic = function()
  local max_chars = ((vim.api.nvim_win_get_width(0)/2)-(require("bartender").center_length()/2))*3/4
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
    highlight = {
      name = "",
    }
  }
end

-- Space character for separating center components
M.get_center_space = function()
  return {
    text      = " ",
    highlight = {
      name = "CenterSpace",
      attributes = {
      },
    },
  }
end



--[[ Edges ]]

-- Left edge/border of center components
M.get_centerside_left_edge = function()
  return {
    text      = "",
    highlight = {
      name = "CentersideLeftEdge",
      attributes = {
        reverse = true
      },
    },
  }
end

-- Right edge/border of center components
M.get_centerside_right_edge = function()
  return {
    text      = "",
    highlight = {
      name = "CentersideRightEdge",
      attributes = {
        reverse = true,
      },
    },
  }
end



--[[ Padding ]]

-- Padding between left screen edge and leftmost component
M.get_left_padding = function()
  return {
    text = " ",
    highlight = {
      name = "Normal",
    },
  }
end

-- Padding between right screen edge and rightmost component
M.get_right_padding = function()
  return {
    text = " ",
    highlight = {
      name = "Normal",
    },
  }
end

-- Padding to keep the center components static
M.get_left_center_padding = function()
  local bartender = require("bartender")
  local diff = 0
  if bartender.left_length() < bartender.right_length() then
    diff = bartender.right_length() - bartender.left_length()
  end

  return {
    text = string.rep(" ", diff),
    highlight = {
      name = "Normal",
    },
  }
end

-- Padding to keep the center components static
M.get_right_center_padding = function()
  local bartender = require("bartender")
  local diff = 0
  if bartender.left_length() > bartender.right_length() then
    diff = bartender.left_length() - bartender.right_length()
  end
  return {
    text = string.rep(" ", diff),
    highlight = {
      name = "Normal",
    },
  }
end

return M
