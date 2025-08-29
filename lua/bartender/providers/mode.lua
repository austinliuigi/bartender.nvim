-- Component showing what mode is currently active

local utils = require("bartender.utils")

---@alias mode "normal"|"insert"|"operator"|"visual"|"vline"|"vblock"|"select"|"sline"|"sblock"|"replace"|"virt-replace"|"command"|"ex"|"prompt"|"shell"|"terminal"

---@type table<mode, bartender.StaticComponent>
local default_mode_to_component = {
  normal = { "NORMAL", hl = {
    reverse = true,
  } },
  insert = {
    "INSERT",
    hl = {},
  },
  operator = {
    "OP-PENDING",
    hl = {
      fg = utils.hl_attr_wrap("Function", "fg"),
      reverse = true,
    },
  },
  visual = {
    "VISUAL",
    hl = "Visual",
  },
  vline = {
    "V-LINE",
    hl = "Visual",
  },
  vblock = {
    "V-BLOCK",
    hl = "Visual",
  },
  select = {
    "SELECT",
    hl = {
      fg = utils.hl_attr_wrap("Visual", "bg"),
      reverse = true,
    },
  },
  sline = {
    "S-LINE",
    hl = {
      fg = utils.hl_attr_wrap("Visual", "bg"),
      reverse = true,
    },
  },
  sblock = {
    "S-BLOCK",
    hl = {
      fg = utils.hl_attr_wrap("Visual", "bg"),
      reverse = true,
    },
  },
  replace = {
    "REPLACE",
    hl = {
      fg = utils.hl_attr_wrap("String", "fg"),
      reverse = true,
    },
  },
  virt_replace = {
    "VIRT-REPLACE",
    hl = {},
  },
  command = {
    "COMMAND",
    hl = {
      fg = utils.hl_attr_wrap("Error", "fg"),
      reverse = true,
    },
  },
  ex = {
    "EX",
    hl = {
      fg = utils.hl_attr_wrap("Error", "fg"),
      reverse = true,
    },
  },
  prompt = {
    "PROMPT",
  },
  shell = {
    "SHELL",
  },
  terminal = {
    "TERMINAL",
    hl = utils.hl_attrs_wrap({ fg = { "Normal", "bg" }, bg = { "DiffAdd", "fg" } }),
  },
}

--- Table that maps mode strings (:h mode()) to mode spec keys
--
local modespec_to_mode = {
  ["n"] = "normal",
  ["niI"] = "normal",
  ["niR"] = "normal",
  ["niV"] = "normal",
  ["nt"] = "normal",
  ["ntT"] = "normal",
  ["no"] = "operator",
  ["nov"] = "operator",
  ["noV"] = "operator",
  ["no"] = "operator",
  ["v"] = "visual",
  ["vs"] = "visual",
  ["V"] = "vline",
  ["Vs"] = "vline",
  [""] = "vblock",
  ["s"] = "vblock",
  ["s"] = "select",
  ["S"] = "sline",
  [""] = "sblock",
  ["i"] = "insert",
  ["ic"] = "insert",
  ["ix"] = "insert",
  ["R"] = "replace",
  ["Rc"] = "replace",
  ["Rx"] = "replace",
  ["Rv"] = "virt_replace",
  ["Rvc"] = "virt_replace",
  ["Rvx"] = "virt_replace",
  ["c"] = "command",
  ["cv"] = "ex",
  ["r"] = "prompt",
  ["rm"] = "prompt",
  ["r?"] = "prompt",
  ["!"] = "shell",
  ["t"] = "terminal",
}

local M = {
  mode_to_component = default_mode_to_component,
}

M.current_mode_hl = function()
  -- return utils.eval_if_func(M.mode_to_component[modespec_to_mode[vim.api.nvim_get_mode().mode]].hl)
  return utils.get_effective_hl_attrs(M.mode_to_component[modespec_to_mode[vim.api.nvim_get_mode().mode]].hl)
end

setmetatable(M, {
  ---@param mode_to_component? table<mode, bartender.StaticComponent>
  __call = function(self, mode_to_component)
    self.mode_to_component = vim.tbl_deep_extend("force", default_mode_to_component, mode_to_component or {})
    return self.mode_to_component[modespec_to_mode[vim.api.nvim_get_mode().mode]], { "ModeChanged" }
  end,
})

return M
