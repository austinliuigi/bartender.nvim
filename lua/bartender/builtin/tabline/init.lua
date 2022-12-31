local sections = require("bartender.builtin.tabline.sections")

return function()
  return {
    sections = {
      sections.tabs()
    }
  }
end
