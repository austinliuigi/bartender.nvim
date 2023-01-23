local bartender = require("bartender")
local utils = require("bartender.utils")

--- Devicons with their proper fg color on section's bg
bartender.add_component("devicon", function()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, _ = require("nvim-web-devicons").get_icon(filename, fileext, { default = true })

  return {
    text      = icon,
    highlight = {
      devicon = true,
    },
  }
end, {"BufEnter"})

bartender.add_component("filepath", function(path_type)
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
    text      = filepath,
    highlight = {
      fg = utils.get_hl("Normal", "foreground"),
    },
  }
end, {"BufEnter"})

bartender.add_component("modified", function()
  return {
    text      = vim.o.modified and " ●" or "",
    highlight = {
      fg = "lightpink",
    },
  }
end)

bartender.add_component("readonly", function()
  return {
    text      = vim.o.readonly and " " or "",
    highlight = {
      fg = "lightblue",
    },
  }
end)





bartender.add_component("space", function()
  return {
    text = " ",
  }
end, "")

bartender.add_component("round_edge_left", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end, "")

bartender.add_component("round_edge_right", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end, "")

bartender.add_component("lower_right_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end, "")

bartender.add_component("upper_left_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end, "")

bartender.add_component("lower_left_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end, "")

bartender.add_component("upper_right_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end, "")

bartender.add_component("lsp_client", function(client)
  return {
    text = client,
    highlight = {
      fg = utils.get_hl("Comment", "foreground")
    }
  }
end, "")



bartender.add_component("navic", function()
  local max_chars = (vim.api.nvim_win_get_width(0)/3)
  if max_chars < 0 then max_chars = 0 end

  local code_context = require("nvim-navic").get_location()
  local code_context_stripped = code_context:gsub("%%%*", ""):gsub("%%%#.-%#", "")

  local ellipsis = "%#NavicText#.."
  while vim.fn.strchars(code_context_stripped) > max_chars do
    local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
    code_context_stripped = code_context:gsub("%%%*", ""):gsub("%%%#.-%#", "")
  end

  return {
    text      = code_context,
    length    = vim.fn.strchars(code_context_stripped),
    highlight = ""
  }
end, { "CursorMoved" })



bartender.add_component("padding", function(rep)
  return {
    text = string.rep(" ", rep),
    highlight = "",
  }
end)

bartender.add_component("separator", function()
  return {
    text = "%=",
  }
end)
