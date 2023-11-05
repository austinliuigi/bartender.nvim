local tail = {}

--- Sharp tail of bar
--
function tail.provider(fg, bg)
  return {
    components = {
      { "", highlight = { fg = fg, bg = bg, reverse = true } },
      { "█", highlight = { fg = fg } },
    }
  }
end


return tail
