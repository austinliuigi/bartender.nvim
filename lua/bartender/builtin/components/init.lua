local builtin_component_names =
  { "bufnr", "cwd", "devicon", "fileformat", "filepath", "lsp_root", "mode", "modified", "navic", "readonly" }

local builtin_components = {}
for _, name in ipairs(builtin_component_names) do
  builtin_components[name] = require(string.format("bartender.builtin.components.%s", name))
end

return builtin_components
