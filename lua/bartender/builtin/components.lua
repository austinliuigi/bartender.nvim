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
    text      = filepath,
    highlight = {
      fg = utils.get_hl("Normal", "foreground"),
    },
  }
end, {"BufEnter"})

bartender.add_component("space", function()
  return {
    text = " ",
  }
end)

bartender.add_component("modified", function()
  return {
    text      = vim.o.modified and " ●" or "",
    highlight = {
      fg = "lightpink",
    },
  }
end)





bartender.add_component("round_edge_left", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end)

bartender.add_component("round_edge_right", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end)

bartender.add_component("lower_right_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end)

bartender.add_component("upper_left_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end)

bartender.add_component("lower_left_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end)

bartender.add_component("upper_right_triangle", function()
  return {
    text      = "",
    highlight = {
      reverse = true
    },
  }
end)

bartender.add_component("lsp_client", function(client)
  return {
    text = client,
    highlight = {
      fg = utils.get_hl("Comment", "foreground")
    }
  }
end)



bartender.add_component("navic", function()
  local sections = require("bartender.builtin.winbar.sections")
  local max_chars = ((vim.api.nvim_win_get_width(0)/2) - (require("bartender").get_section_length(sections.center())/2))*3/4
  if max_chars < 0 then max_chars = 0 end

  local code_context = require("nvim-navic").get_location()                  -- Note: includes statusline/winbar highlighting
  -- local code_context_underwear = string.gsub(code_context, "%%%#.-%#", "")   -- Remove any highlight codes (e.g. %#Group#)
  -- local code_context_naked = string.gsub(code_context_underwear, "%%%*", "") -- Remove any default highlight codes (%*)
  local code_context_nohl = code_context:gsub("%%%*", ""):gsub("%%%#.-%#", "")

  local ellipsis = "%#NavicText#.."
  while vim.fn.strchars(code_context_nohl) > max_chars do
    local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
    -- code_context_underwear = string.gsub(code_context, "%%%#.-%#", "")
    code_context_nohl = code_context:gsub("%%%*", ""):gsub("%%%#.-%#", "")
  end

  return {
    text      = code_context,
    length    = vim.fn.strchars(code_context_nohl),
    highlight = ""
  }
end)






bartender.add_section("left", function()
  local clients = {}

  for _, client in ipairs(vim.lsp.get_active_clients({bufnr = 0})) do
    table.insert(clients, { "lsp_client", args = {client.name} })
    -- table.insert(clients, { "space" })
  end

  return {
    bg = nil,
    components = clients,
  }
end, { "LspAttach", "LspDetach" })

bartender.add_section("center", function()
  return {
    bg = utils.get_hl("Comment", "foreground"),
    components ={
      { "round_edge_left" },
      { "devicon" },
      { "space" },
      { "filepath", args = {"abs"} },
      { "modified" },
      { "round_edge_right" },
    }
  }
end, {"VimEnter"})

bartender.add_section("right", function()
  return {
    bg = nil,
    components ={
      { "navic" }
    }
  }
end, {"VimEnter"})
