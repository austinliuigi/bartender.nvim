local M

--- Benchmark how long it takes to run function n times
---
---@param unit "seconds"|"milliseconds"|"microseconds"|"nanoseconds" Unit of time to display
---@param dec_places integer Number of decimal places to show
---@param n integer Number of times to run function
---@param f function Function to run
---@param ... any Arguments for function
local function benchmark(unit, dec_places, n, f, ...)
  local units = {
    ["seconds"] = 1,
    ["milliseconds"] = 1000,
    ["microseconds"] = 1000000,
    ["nanoseconds"] = 1000000000,
  }
  local elapsed = 0
  local multiplier = units[unit]
  for _ = 1, n do
    local now = os.clock()
    f(...)
    elapsed = elapsed + (os.clock() - now)
  end
  print(
    string.format(
      "Benchmark results:\n  - %d function calls\n  - %."
        .. dec_places
        .. "f %s elapsed\n  - %."
        .. dec_places
        .. "f %s avg execution time.",
      n,
      elapsed * multiplier,
      unit,
      (elapsed / n) * multiplier,
      unit
    )
  )
end

--- Benchmark how long it takes to compute bar
---
---@param bar bartender.Bar
---@param variant bartender.BarVariant
M.run = function(bar, variant)
  local component_group = require("bartender.config")[bar][variant]
  if component_group == nil then
    vim.notify("Bartender: Bar variant is not configured", vim.log.levels.ERROR, { title = "Bartender" })
    return
  end
  benchmark("milliseconds", 2, 1e4, function()
    require("bartender.resolve").resolve_component_group(bar, "BartenderBenchmark", 1)
  end)
end

return M
