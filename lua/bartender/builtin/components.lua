local utils = require("bartender.utils")


local components = {}


--- Devicons with their proper fg color
--
function components.devicon()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, color = require("nvim-web-devicons").get_icon(filename, fileext, { default = true })

  return {
    text = icon,
    highlight = {
      fg = utils.get_hightlight_attr(color, "foreground"),
    },
  }, { "BufEnter" }
end


--- Filepath of current buffer
--
---@param path_type "tail"|"rel"|"abs" Type of path to output
---@param truncate_length integer
function components.filepath(path_type, truncate_length)
  path_type = path_type or "tail"
  local filepaths = { tail = "%:t", rel = "%:.", abs = "%:p:~" }
  local filepath = vim.fn.expand(filepaths[path_type])

  if filepath == "" then filepath = "???" end

  local truncate_width = vim.api.nvim_win_get_width(0)/3
  local truncate_length = 5
  while #vim.fn.expand(filepath) > truncate_width and truncate_length >= 1 do
    filepath = vim.fn.pathshorten(filepath, truncate_length)
    truncate_length = truncate_length - 1
  end

  return {
    text = filepath,
    highlight = {
      fg = utils.get_hightlight_attr("Normal", "foreground"),
    },
  }, { "BufEnter" }
end


--- Icon showing if current buffer is has been modified
--
function components.modified()
  return {
    text = vim.o.modified and "●" or "",
    highlight = {
      fg = "lightpink",
    },
  }
end


--- Icon showing if current buffer is has been modified
--
function components.readonly()
  return {
    text = vim.o.readonly and "" or "",
    highlight = {
      fg = "lightblue",
    },
  }
end





function components.space()
  return {
    text = " ",
  }
end

function components.round_edge_left()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

function components.round_edge_right()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

function components.lower_right_triangle()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

function components.upper_left_triangle()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

function components.lower_left_triangle()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

function components.upper_right_triangle()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end

function components.lsp_client(client)
  return {
    text = client,
    highlight = {
      fg = utils.get_hightlight_attr("Comment", "foreground")
    }
  }
end



--- Navic
function components.navic(max_chars)
  local max_chars = max_chars or (vim.api.nvim_win_get_width(0)/3)

  local code_context = require("nvim-navic").get_location()
  local code_context_raw = code_context:gsub("%%%*", ""):gsub("%%%#.-%#", "")

  local ellipsis = "%#NavicText#.."
  while vim.fn.strchars(code_context_raw) > max_chars do
    local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
    code_context_raw = code_context:gsub("%%%*", ""):gsub("%%%#.-%#", "")
  end

  return {
    text      = code_context,
    length    = vim.fn.strchars(code_context_raw),
    highlight = ""
  }, { "CursorMoved" }
end



function components.padding(rep)
  return {
    text = string.rep(" ", rep),
    highlight = "",
  }
end

function components.separator()
  return {
    text = "%=",
  }
end

return components
