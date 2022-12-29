local sections = require("bartender.builtin.winbar.sections")

return function()
  return {
    sections = {
      sections.left(),
      sections.left_center_padding(),
      sections.center(),
      sections.right_center_padding(),
      sections.right(),
    },
  }
end
