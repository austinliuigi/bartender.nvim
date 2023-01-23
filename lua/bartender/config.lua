local config = {
    filepath_type = "tail", -- "tail" | "rel" | "abs"
    highlight_prefix = "Bartender",
    winbar = {
      active = {
        { name = "left" },
        { name = "left_padding", args = { "winbar", "active", { "left" }, { "right" } } },
        { name = "center" },
        { name = "right_padding", args = { "winbar", "active", { "left" }, { "right" } } },
        { name = "right" },
      },
      inactive = {
        { name = "left" },
        { name = "left_padding", args = { "winbar", "inactive", { "left" }, { "right" } } },
        { name = "center" },
        { name = "right_padding", args = { "winbar", "inactive", { "left" }, { "right" } } },
        { name = "right" },
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
