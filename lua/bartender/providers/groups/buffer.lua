local providers = require("bartender.providers")

return function()
  return {
    { providers.devicon },
    { " " },
    { providers.filepath, args = { 0, ":~:." } },
    { providers.modified, args = { " ●" } },
    { providers.readonly, args = { " " } },
  }, {}
end
