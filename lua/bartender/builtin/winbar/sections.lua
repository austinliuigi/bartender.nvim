local components = require("bartender.builtin.winbar.components")
local utils = require("bartender.utils")

local M = {}

-- M.left = function()
--   return {
--     bg = nil,
--     components = {
--       components.get_lsp_clients(),
--     }
--   }
-- end
M.left = function()
  local clients = {}

  for _, client in ipairs(vim.lsp.get_active_clients({bufnr = 0})) do
    table.insert(clients, components.test_lsp(client.name))
  end

  return {
    bg = nil,
    components = clients,
  }
end
-- M.left = function()
--   return {
--     bg = nil,
--     components = {
--       components.get_lsp_symbol(),
--       components.get_devicon(),
--     }
--   }
-- end

M.left_center_padding = function()
  return {
    bg = nil,
    components = {
      components.get_separator(),
      components.get_left_center_padding()
    }
  }
end

M.center = function()
  return {
    bg = utils.get_hl("Comment", "foreground"),
    components = {
      components.get_centerside_left_edge(),
      components.get_devicon(),
      components.get_center_space(),
      components.get_filepath(require("bartender.config").filepath_type),
      components.get_readonly(),
      components.get_modified(),
      components.get_centerside_right_edge(),
    }
  }
end

M.right_center_padding = function()
  return {
    bg = nil,
    components = {
      components.get_right_center_padding(),
      components.get_separator(),
    }
  }
end

M.right = function()
  return {
    bg = nil,
    components = {
      components.get_navic(),
      components.get_right_padding(),
    }
  }
end

return M
