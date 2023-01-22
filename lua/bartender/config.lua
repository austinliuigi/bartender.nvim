local config = {
    filepath_type = "tail", -- "tail" | "rel" | "abs"
    highlight_prefix = "Bartender",
    winbar = {
      active = {
        { "left" },
        { "center" },
        { "right" },
      },
      inactive = {
        { "left" },
        { "center" },
        { "right" },
      },
    },
    statusline = {
      active = nil,
      inactive = nil,
      global = nil
    },
    tabline = nil,
    winbar_deprecated = require("bartender.builtin.winbar"),
    statusline_deprecated = nil,
    tabline_deprecated = require("bartender.builtin.tabline"),
}

return config
