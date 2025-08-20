local components = require("bartender.builtin.components")

return function()
  return {
    { components.devicon },
    { " " },
    { components.filepath, args = { 0, ":~:." } },
    { components.modified, args = { " ●" } },
    { components.readonly, args = { " " } },
  }, {}
end
