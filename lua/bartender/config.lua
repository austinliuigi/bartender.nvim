local M = {}

local default_config = {
  winbar = nil,
  statusline = nil,
  tabline = nil,
  statuscolumn = nil,
}

M.config = default_config

local has_configured = false
M.configure = function(cfg, base)
  cfg = cfg or {}
  base = base or "default"

  local new_config
  if base == "default" then
    new_config = vim.tbl_deep_extend("force", default_config, cfg)
  elseif base == "current" then
    new_config = vim.tbl_deep_extend("force", M.config, cfg)
  elseif base == "none" then
    new_config = cfg
  end

  for k, v in pairs(new_config) do
    M.config[k] = v
  end

  has_configured = true
end

setmetatable(M, {
  __index = function(self, key)
    if not has_configured then
      M.configure()
    end

    return M.config[key] or rawget(self, key)
  end,
})

return M
