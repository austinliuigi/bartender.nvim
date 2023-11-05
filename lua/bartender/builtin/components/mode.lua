---@class mode_spec
---@field text string text that should be shown for mode
---@field highlight table|function highlight attribute table


local utils = require("bartender.utils")
local mode = {}


--- Table that maps modes to their respective mode_specs
--
mode.mode_specs = {
  normal = { text = "NORMAL",
    highlight = {
      reverse = true,
    }
  },
  operator = {
    text = "OP-PENDING",
    highlight = function()
      return {
      fg = utils.get_hl_attr("Function", "fg"),
      reverse = true,
      }
    end
  },
  visual = {
    text = "VISUAL",
    highlight = "Visual"
  },
  vline = {
    text = "V-LINE",
    highlight = "Visual"
  },
  vblock = {
    text = "V-BLOCK",
    highlight = "Visual"
  },
  select = {
    text = "SELECT",
    highlight = function()
      return {
        fg = utils.get_hl_attr("Visual", "bg"),
        reverse = true,
      }
    end
  },
  sline = {
    text = "S-LINE",
    highlight = function()
      return {
        fg = utils.get_hl_attr("Visual", "bg"),
        reverse = true,
      }
    end
  },
  sblock = {
    text = "S-BLOCK",
    highlight = function()
      return {
        fg = utils.get_hl_attr("Visual", "bg"),
        reverse = true,
      }
    end
  },
  insert = {
    text = "INSERT",
    highlight = {
    }
  },
  replace = {
    text = "REPLACE",
    highlight = {
    }
  },
  virt_replace = {
    text = "VIRT-REPLACE",
    highlight = {
    }
  },
  command = {
    text = "COMMAND",
    highlight = function()
      return {
      fg = utils.get_hl_attr("Error", "fg"),
      reverse = true,
      }
    end
  },
  ex = {
    text = "EX",
    highlight = function()
      return {
      fg = utils.get_hl_attr("Error", "fg"),
      reverse = true,
      }
    end
  },
  prompt = {
    text = "PROMPT",
    highlight = {
    }
  },
  shell = {
    text = "SHELL",
    highlight = {
    }
  },
  terminal = {
    text = "TERMINAL",
    highlight = {
    }
  },
}


--- Table that maps mode strings (:h mode()) to mode specs
--
mode.mode_string_map = {
  ["n"]    = mode.mode_specs.normal,
  ["niI"]  = mode.mode_specs.normal,
  ["niR"]  = mode.mode_specs.normal,
  ["niV"]  = mode.mode_specs.normal,
  ["nt"]   = mode.mode_specs.normal,
  ["ntT"]  = mode.mode_specs.normal,
  ["no"]   = mode.mode_specs.operator,
  ["nov"]  = mode.mode_specs.operator,
  ["noV"]  = mode.mode_specs.operator,
  ["no"] = mode.mode_specs.operator,
  ["v"]    = mode.mode_specs.visual,
  ["vs"]   = mode.mode_specs.visual,
  ["V"]    = mode.mode_specs.vline,
  ["Vs"]   = mode.mode_specs.vline,
  [""]   = mode.mode_specs.vblock,
  ["s"]  = mode.mode_specs.vblock,
  ["s"]    = mode.mode_specs.select,
  ["S"]    = mode.mode_specs.sline,
  [""]   = mode.mode_specs.sblock,
  ["i"]    = mode.mode_specs.insert,
  ["ic"]   = mode.mode_specs.insert,
  ["ix"]   = mode.mode_specs.insert,
  ["R"]    = mode.mode_specs.replace,
  ["Rc"]   = mode.mode_specs.replace,
  ["Rx"]   = mode.mode_specs.replace,
  ["Rv"]   = mode.mode_specs.virt_replace,
  ["Rvc"]  = mode.mode_specs.virt_replace,
  ["Rvx"]  = mode.mode_specs.virt_replace,
  ["c"]    = mode.mode_specs.command,
  ["cv"]   = mode.mode_specs.ex,
  ["r"]    = mode.mode_specs.prompt,
  ["rm"]   = mode.mode_specs.prompt,
  ["r?"]   = mode.mode_specs.prompt,
  ["!"]    = mode.mode_specs.shell,
  ["t"]    = mode.mode_specs.terminal,
}


--- Get the text for the current mode
--
---@return string
function mode.get_current_mode_text()
  return mode.mode_string_map[vim.api.nvim_get_mode().mode].text
end


--- Get the highlight attr table for the current mode
--
---@return table highlight
function mode.get_current_mode_highlight()
  local hl = utils.eval_if_func(mode.mode_string_map[vim.api.nvim_get_mode().mode].highlight)
  if type(hl) == "string" then
    hl = utils.get_hl_attrs(hl)
  end
  return hl
end


--- Get the highlight attribute table for the current mode with reverse toggled
--
---@return table attrs
function mode.get_current_mode_highlight_reversed()
  local mode_component_hl = mode.get_current_mode_highlight()

  return vim.tbl_deep_extend('force',
    mode_component_hl,
    { reverse = not mode_component_hl.reverse }
  )
end


--- Current (neo)vim mode
--
function mode.provider()
  return {
    text = mode.get_current_mode_text(),
    highlight = mode.get_current_mode_highlight(),
  }, { "ModeChanged" }
end


return mode
