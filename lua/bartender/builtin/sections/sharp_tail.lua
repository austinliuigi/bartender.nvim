local tail = {}

--- Sharp tail of bar
--
function tail.provider(fg, bg)
  return {
    components = {
      { "", highlight = { fg = bg, bg = nil, reverse = true } },
      { "█", highlight = { fg = bg } },
    },
  }
end

return tail
