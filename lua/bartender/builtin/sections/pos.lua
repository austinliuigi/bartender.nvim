local pos = {}

--- Pos of cursor
--
function pos.provider(color)
  return {
    components = {
      { "", highlight = { fg = color } },
      { " ", highlight = { bg = color } },
      { "%l", highlight = { fg = color, reverse = true } },
      { ":", highlight = { fg = color, reverse = true } },
      { "%v", highlight = { fg = color, reverse = true } },
      { " ", highlight = { bg = color } },
    },
  }
end

return pos
