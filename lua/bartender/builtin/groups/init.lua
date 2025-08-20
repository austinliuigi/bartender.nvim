local builtin_group_names = { "buffer", "cwd", "head", "mode", "pos", "tabs", "tail" }

local builtin_groups = {}
for _, name in ipairs(builtin_group_names) do
  builtin_groups[name] = require(string.format("bartender.builtin.groups.%s", name))
end

return builtin_groups
