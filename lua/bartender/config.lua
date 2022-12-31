local config = {
    filepath_type = "tail", -- "tail" | "rel" | "abs"
    highlight_prefix = "Bartender",
    winbar = require("bartender.builtin.winbar"),
    statusline = nil,
    tabline = require("bartender.builtin.tabline"),
}

return config
