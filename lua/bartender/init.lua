local highlights = require("bartender.highlights")
local config = require("bartender.config")
local cache = require("bartender.cache")

local bartender = {}



--- Run supplied function only after VimEnter has been triggered
---
---@param func function Function to call
local function on_or_after_vimenter(func)
  if vim.v.vim_did_enter == 1 then
    func()
  else
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
      callback = func,
      once = true,
    })
  end
end



--- Check if supplied bar is window-local (as opposed to global)
---
---@param bar string
local function is_local(bar)
  if bar == "winbar" or (bar == "statusline" and vim.o.laststatus ~= 3) then
    return true
  end
  return false
end



--- Delete autogroup and any contained autocommands
local function delete_augroup(group)
  vim.api.nvim_create_augroup(group, {clear = true})
  vim.api.nvim_del_augroup_by_name(group)
end



--- Make parent tables if they don't exist
---
---@param base table
---@param ...
local function ensure_tables(base, ...)
  local tbl = base
  local args = {...}

  for _, child in ipairs(args) do
    if child == nil then return false end

    if tbl[child] == nil then
      tbl[child] = {}
    elseif tbl[child] ~= "table" then
      return false
    end

    tbl = tbl[child]
  end
end



--- Check if bar should be disabled for window
local function is_disabled(winid, bufnr)
  winid = winid or vim.api.nvim_get_current_win()
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.api.nvim_win_get_config(winid).zindex ~= nil then
    return true
  end
  if vim.bo.buftype == "terminal" then
    return true
  end
end



--- Get the autogroup name for a bar's section/component
---
---@param type "section"|"component"
---@param bar string
---@param section_index integer
---@param winid integer|nil
local function get_cache_augroup_name(type, bar, variant, section_index, winid)
  local capitalize = require("bartender.utils").capitalize

  if type == "section" then
    return string.format("BartenderUpdate%s%sSection%s%s", capitalize(bar), capitalize(variant), section_index, winid and "(Window"..winid..")" or "")
  elseif type == "component" then
    return string.format("BartenderUpdate%s%sSection%sComponents%s", capitalize(bar), capitalize(variant), section_index, winid and "(Window"..winid..")" or "")
  end
  return false
end



--- Ensure config is correct
bartender.validate_config = function()
  vim.validate({
    winbar = { config.winbar, "table", true },
    statusline = { config.statusline, "table", true },
    tabline = { config.tabline, "table", true },
  })
end



--- Add builtin components
local function add_builtins()
  require("bartender.builtin.components")
end



--- Setup the cache and autocommands for each operational (in-use) section/component to keep it updated
--- For global bars, the entire bar gets a single entry in cache
--- For local bars, each window gets its own entry in cache
--- Each entry in cache consists of autocmds to update the section and components of that bar
---
---@param bar string
---@param winid integer|nil ':h window-ID' if bar is local to a window
local function add_cache_entry(bar, winid)
  local window_local = is_local(bar)
  local variants = { "active", "inactive" }
  if not window_local then
    winid = vim.api.nvim_get_current_win()
    variants = { "global" }
  end

  local capitalize = require("bartender.utils").capitalize

  for _, variant in ipairs(variants) do
    -- Extract the bar table (table of section_tables)
    local config_bar_section_table, cache_bar_table = config[bar][variant], cache.bars[bar][variant]
    if config_bar_section_table == nil then return end

    if window_local then
      cache_bar_table[winid] = {}
      cache_bar_table = cache_bar_table[winid]
    end

    -- For each section_table supplied in config
    for section_index, section_table in ipairs(config_bar_section_table) do
      local section_name = section_table[1]
      if section_table.args == nil then section_table.args = {} end
      local section_events = cache.section_lib[section_name].events

      if section_events == nil then
        -- Recompute components on each statusline refresh
      else
        -- Create autocmd to recompute which components are contained in section
        local bar_variant_section_augroup = get_cache_augroup_name("section", bar, variant, section_index, window_local and winid or nil)
        vim.api.nvim_create_augroup(bar_variant_section_augroup, {clear = true})
        vim.api.nvim_create_autocmd(section_events, {
          group   = bar_variant_section_augroup,
          pattern = {'*'},
          callback = function()
            local section = cache.section_lib[section_name].callback(unpack(section_table.args))

            -- Flush section's cache entry of its previous value
            cache_bar_table[section_index] = {bg = section.bg, components = {}}

            -- Create/clear autogroup for section components
            local bar_variant_section_components_augroup = get_cache_augroup_name("component", bar, variant, section_index, window_local and winid or nil)
            vim.api.nvim_create_augroup(bar_variant_section_components_augroup, {clear = true})

            -- For each component in section
            for component_index, component_table in ipairs(section.components) do
              local component_name = component_table[1]
              if component_table.args == nil then component_table.args = {} end
              local component_events = cache.component_lib[component_name].events

              if component_events == nil then
                -- Make the value in cache the callback function to call on each statusline refresh
                cache_bar_table[section_index].components[component_index] = {
                  name = component_table[1],
                  callback = cache.component_lib[component_name].callback,
                  args = component_table.args,
                }
              else
                -- Create an autocmd to update component table in the cache
                vim.api.nvim_create_autocmd(component_events, {
                  group = bar_variant_section_components_augroup,
                  pattern = "*",
                  -- pattern = (not window_local) and '*' or nil,
                  -- buffer = window_local and 0 or nil, -- make autocmd local to buffer if bar is local to window
                  once = (#component_events == 0), -- only compute once if event is "" or {},
                  callback = function()
                    cache_bar_table[section_index].components[component_index] = vim.api.nvim_win_call(winid, function() return cache.component_lib[component_name].callback(unpack(component_table).args) end)
                  end,
                })
                vim.api.nvim_exec_autocmds(component_events, {group = bar_variant_section_components_augroup})
              end
            end
          end,
        })
        vim.api.nvim_exec_autocmds(cache.section_lib[section_name].events, {group = bar_variant_section_augroup, pattern = "*"})
      end
    end
  end
end



--- Wipe entry from cache and delete any autocmd/groups associated with it
---
---@param bar string
---@param winid integer|nil
local function remove_cache_entry(bar, winid)
  local variants = winid and {"active", "inactive"} or {"global"}

  -- If window local, remove specific window's entry (set to nil) for both active and inactive and delete its autocommands
  for _, variant in ipairs(variants) do
    local entry = cache.bars[bar][variant]
    if entry == nil then return end

    if winid then entry = entry[winid] end
    if entry == nil then return end

    for section_index, section in ipairs(entry) do
      delete_augroup(get_cache_augroup_name("component", bar, variant, section_index, winid))
      delete_augroup(get_cache_augroup_name("section", bar, variant, section_index, winid))
      entry = nil
    end
  end
  -- Elseif global, remove entire bar entry (set to {}) and delete its autocommands
end



--- Set winbar/statusline/tabline vim option
---
---@param bar string
local function set_option(bar)
  local options = {
    active = "%{%v:lua.require('bartender').get_bar_string('"..bar.."', 'active')%}",
    inactive = "%{%v:lua.require('bartender').get_bar_string('"..bar.."', 'inactive')%}",
    global = "%{%v:lua.require('bartender').get_bar_string('"..bar.."', 'global')%}",
  }

  local group_name = "BartenderSetLocal" .. require("bartender.utils").capitalize(bar)

  if is_local(bar) then
    -- Set local option for each open window
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      local current_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_call(winid, function() vim.wo[bar] = (winid == current_win) and options.active or options.inactive end)
    end
    -- Create autocommands to set local options when switching windows
    vim.api.nvim_create_augroup(group_name, {clear = true})
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      group = group_name,
      pattern = {'*'},
      callback = vim.schedule_wrap(function()
        -- Use schedule_wrap so is_disabled is eval'ed after buffer is loaded
        if not is_disabled() then
          vim.wo[bar] = options.active
          -- vim.wo[bar] = "%{%v:lua.require('bartender').set_active('winbar')%}"
        end
      end)
    })
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
      group = group_name,
      pattern = {'*'},
      callback = vim.schedule_wrap(function()
        if not is_disabled() then
          -- TODO: Check if autocommands pass winid of window that you leave
          vim.wo[bar] = options.inactive
        end
      end)
    })
  else
    -- Remove any local options (in case bar switched from local to global)
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      vim.wo[bar] = ""
    end
    delete_augroup(group_name)

    vim.o[bar] = options.global
  end
end



--- Get bar to state where it works
---
---@param bar string
local function setup_bar_cache(bar)
  local group_name = "BartenderAddLocal" .. require("bartender.utils").capitalize(bar)

  if is_local(bar) then
    -- Remove global entry if exists
    remove_cache_entry(bar, nil)

    -- Create cache entries for each open window
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      add_cache_entry(bar, winid)
    end

    -- Create autocmds to add/remove window-local entries in cache
    vim.api.nvim_create_augroup(group_name, {clear = true})
    vim.api.nvim_create_autocmd({ "WinNew" }, {
      group   = group_name,
      pattern = {'*'},
      callback = function()
        -- Add entry only after buffer has loaded into the new window
        vim.schedule(function()
          add_cache_entry(bar, vim.api.nvim_get_current_win())
        end)
      end,
    })
    vim.api.nvim_create_autocmd({ "WinClosed" }, {
      group   = group_name,
      pattern = {'*'},
      callback = function(arg)
        local winid = tonumber(arg.match)
        if not is_disabled(winid) then
          remove_cache_entry(bar, winid)
        end
      end,
    })
  else

    -- Remove any local entries (in case bar switched from local to global)
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      remove_cache_entry(bar, winid)
    end
    -- Delete any local autocommands
    delete_augroup(group_name)

    add_cache_entry(bar)
  end
end



--- Get bar up and running
local function initialize_bars()
  if config.winbar ~= nil then
    setup_bar_cache("winbar")
    set_option("winbar")
  end
  local statusline_group = "BartenderChangeStatuslineType"
  if config.statusline ~= nil then
    vim.api.nvim_create_augroup(statusline_group, {clear = true})
    vim.api.nvim_create_autocmd("OptionSet", {
      group = statusline_group,
      pattern = "laststatus",
      callback = function()
        setup_bar_cache("statusline")
        set_option("statusline")
      end
    })
    vim.api.nvim_exec_autocmds("OptionSet", {group = statusline_group, pattern = "laststatus"})
  end
  if config.tabline ~= nil then
    setup_bar_cache("tabline")
    set_option("tabline")
  end
end



--- Setup plugin - Can be called multiple times; remembers previous config values
---
---@param cfg table Config table
bartender.setup = function(cfg)
  -- Extend config table with provided values
  for key, value in pairs(cfg) do
    config[key] = value
  end
  bartender.validate_config()

  add_builtins()

  on_or_after_vimenter(function()
    initialize_bars()
  end)
end



--- Add component to library of available components
---
---@param name string Name of component
---@param callback function Function that returns component table
---@param events string|table Events that trigger the component to update
bartender.add_component = function(name, callback, events)
  -- Return name of component in addition to what callback returns
  cache.component_lib[name] = {callback = function(...)
    local component = callback(...)
    component.name = name
    return component
  end, events = events}
end



--- Add section to library of available sections
---
---@param name string Name of section
---@param callback function Function that returns section table
---@param events string|table Events that trigger the section to update
bartender.add_section = function(name, callback, events)
  -- Return name of section in addition to what callback returns
  cache.section_lib[name] = {callback = function(...)
    local section = callback(...)
    section.name = name
    return section
  end, events = events}
end



--- Get length(number of characters) of section
---
---@param section table
bartender.get_section_length = function(section)
  local sum = 0
  for _, component in ipairs(section.components) do
    local component_length = component.length or vim.fn.strchars(component.text)
    sum = sum + component_length
  end
  return sum
end



--- Benchmark how long it takes to run function n times
---
---@param unit "seconds"|"milliseconds"|"microseconds"|"nanoseconds" Unit of time to display
---@param dec_places integer Number of decimal places to show
---@param n integer Number of times to run function
---@param f function Function to run
---@param ... Arguments for function
local function benchmark(unit, dec_places, n, f, ...)
  local units = {
    ['seconds'] = 1,
    ['milliseconds'] = 1000,
    ['microseconds'] = 1000000,
    ['nanoseconds'] = 1000000000
  }
  local elapsed = 0
  local multiplier = units[unit]
  for i = 1, n do
    local now = os.clock()
    f(...)
    elapsed = elapsed + (os.clock() - now)
  end
  print(string.format('Benchmark results:\n  - %d function calls\n  - %.'.. dec_places ..'f %s elapsed\n  - %.'.. dec_places ..'f %s avg execution time.', n, elapsed * multiplier, unit, (elapsed / n) * multiplier, unit))
end

--- Benchmark how long it takes to compute bar
---
---@param bar "winbar"|"statusline"|"tabline"
---@param variant "active"|"inactive"|"global"|nil
bartender.benchmark = function(bar, variant)
  benchmark("milliseconds", 2, 1000, function()
    bar = bar or "winbar"
    variant = variant or "active"
    bartender.set_active("winbar")
    -- bartender.get_bar_string('winbar', 'active')
  end)
end



--- Get the string for the variant of bar
---
---@param bar "winbar"|"statusline"|"tabline"
---@param variant "active"|"inactive"|"global"
bartender.get_bar_string = function(bar, variant)
  local bar_strings = {}
  local winid = vim.api.nvim_get_current_win()
  local cache_bar_table = cache.bars[bar][variant]
  if is_local(bar) then cache_bar_table = cache_bar_table[winid] end
  if cache_bar_table == nil then return "" end

  for section_index, section in ipairs(cache_bar_table) do
    for component_index, component in ipairs(section.components) do
      -- Handle case when event is nil (update on each statusline refresh)
      local continuously_upate = (component.callback ~= nil)
      if continuously_upate then
        component = component.callback(unpack(component.args))
      end

      local highlight_name
      if type(component.highlight) == "table" then
        highlight_name = highlights.get_highlight_name(bar, section_index, section, component_index, component)
        -- Define highlight if it was never defined or if it does not have a foreground color defined
        -- Second condition is necessary b/c if a change in colorscheme clears a highlight, hlexists still
        -- outputs true if it was defined before, even after it gets cleared
        if vim.fn.hlexists(highlight_name) == 0 or vim.api.nvim_get_hl_by_name(highlight_name, true).foreground == nil then
          highlights.create_highlight(highlight_name, component, section.bg)
        end
      else
        highlight_name = component.highlight
      end

      local highlight_string = (highlight_name == nil) and "" or ("%#"..highlight_name.."#")

      table.insert(bar_strings, highlight_string .. component.text)
    end
  end
  return table.concat(bar_strings)
end









bartender.set_active = function(bar)
  local bar_text = {}

  local bars = {
    winbar = config.winbar_deprecated,
    statusline = config.statusline_deprecated,
    tabline = config.tabline_deprecated,
  }

  if bars[bar] == nil then return end

  local sections = bars[bar]().sections

  for index, section in ipairs(sections) do
    for idx, component in ipairs(section.components) do
      local highlight_name
      if type(component.highlight) == "table" then
        highlight_name = highlights.get_highlight_name(bar, index, section, idx, component)
        if vim.fn.hlexists(highlight_name) == 0 or vim.api.nvim_get_hl_by_name(highlight_name, true).foreground == nil then
          highlights.create_highlight(highlight_name, component, section.bg)
        end
      else
        highlight_name = component.highlight
      end


      table.insert(bar_text, "%#" .. highlight_name .. "#" .. component.text)
    end
  end

  return table.concat(bar_text)
end

bartender.set_inactive = bartender.set_active


-- [[ Autocommands ]


-- -- Set highlights after changing colorschemes
-- vim.api.nvim_create_augroup("BartenderHighlights", {clear = true})
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   group   = "BartenderHighlights",
--   pattern = {'*'},
--   callback = function()
--     for _, bar in ipairs({"winbar", "statusline", "tabline"}) do
--       if config[bar] ~= nil then
--         for _, section in ipairs(config[bar]().sections) do
--           for _, component in ipairs(section.components) do
--             highlights.create_highlight(component, section.bg)
--           end
--         end
--       end
--     end
--   end,
-- })


return bartender
