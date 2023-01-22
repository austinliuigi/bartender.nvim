return {
  -- Library of available components
  component_lib = {},
  -- Library of available sections
  section_lib = {},
  -- Snapshots of sections and components for each bar
  bars = {
    winbar = {
      active = {},
      inactive = {},
    },
    statusline = {
      active = nil,
      inactive = nil,
      global = nil,
    },
    tabline = nil
  }
}
