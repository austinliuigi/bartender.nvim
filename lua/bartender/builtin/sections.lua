local components = require("bartender.builtin.components")
local utils = require("bartender.utils")

local sections = {}

function sections.test()
  return {
    components = {
      { components.devicon },
    }
  }
end

function sections.test_inactive()
  return {
    components = {
      { components.modified },
    }
  }
end

return sections



-- bartender.add_section("left", function()
--   local clients = {}
--
--   for _, client in ipairs(vim.lsp.get_active_clients({bufnr = 0})) do
--     table.insert(clients, { name = "lsp_client", args = {client.name} })
--     -- table.insert(clients, { "space" })
--   end
--
--   return {
--     bg = nil,
--     components = clients,
--   }
-- end, { "LspAttach", "LspDetach", "BufEnter" })
--
-- bartender.add_section("left_padding", function(bar, variant, left_sections, right_sections)
--   local left_length = 0
--   for _, section in ipairs(left_sections) do
--     left_length = left_length + bartender.get_section_length(bar, variant, section)
--   end
--
--   local right_length = 0
--   for _, section in ipairs(right_sections) do
--     right_length = right_length + bartender.get_section_length(bar, variant, section)
--   end
--
--   return {
--     bg = nil,
--     components = {
--       { name = "separator" },
--       { name = "padding", args = { (right_length > left_length) and (right_length - left_length) or 0} }
--     }
--   }
-- end)
--
-- bartender.add_section("center", function()
--   return {
--     bg = utils.get_hightlight_attr("Comment", "foreground"),
--     components ={
--       { name = "round_edge_left" },
--       { name = "devicon" },
--       { name = "space" },
--       { name = "filepath", args = {"tail"} },
--       { name = "modified" },
--       { name = "readonly" },
--       { name = "round_edge_right" },
--     }
--   }
-- end)
--
-- bartender.add_section("right_padding", function(bar, variant, left_sections, right_sections)
--   local left_length = 0
--   for _, section in ipairs(left_sections) do
--     left_length = left_length + bartender.get_section_length(bar, variant, section)
--   end
--
--   local right_length = 0
--   for _, section in ipairs(right_sections) do
--     right_length = right_length + bartender.get_section_length(bar, variant, section)
--   end
--
--   return {
--     bg = nil,
--     components = {
--       { name = "separator" },
--       { name = "padding", args = { (left_length > right_length) and (left_length - right_length) or 0} }
--     }
--   }
-- end)
--
-- bartender.add_section("right", function()
--   return {
--     bg = nil,
--     components ={
--       { name = "navic" }
--     }
--   }
-- end, {"VimEnter"})
