-- https://github.com/luukvbaal/statuscol.nvim/tree/0.10/lua/statuscol
-- - we rename the foldinfo_T fields, which are defined in neovim/src/nvim/fold_defs.h for semantic understanding
-- - fold_info() is defined in neovim/src/nvim/fold.c
local ffi = require("ffi")
ffi.cdef([[
  typedef struct {} Error;
  typedef struct {} win_T;
  typedef struct {
    int start;  // line number where deepest fold starts
    int level;  // fold level, when zero other fields are N/A
    int llevel; // lowest level that starts in v:lnum
    int lines;  // number of lines from v:lnum to end of closed fold
  } foldinfo_T;
  foldinfo_T fold_info(win_T* wp, int lnum);
  win_T *find_window_by_handle(int Window, Error *err);
  int getDeepestNesting(win_T* wp);
]])
local error = ffi.new("Error")

---@class foldinfo_T
---@field start integer
---@field level integer
---@field llevel integer
---@field lines integer

-- HACK
-- Create an artificial CursorHold event
--   - https://github.com/neovim/neovim/issues/21533#issuecomment-1368070250
local TIMEOUT = 350
local timer = vim.loop.new_timer()
vim.on_key(function()
  timer:start(TIMEOUT, 0, function()
    vim.schedule(function()
      vim.cmd("redraw!")
      -- vim.api.nvim__redraw({ statuscolumn = true })
    end)
  end)
end)

--==================================================================================================
-- Utils
--==================================================================================================

local function get_effective_foldlevel(win, lnum, foldinfo)
  if foldinfo.lines == 0 then -- if fold is open
    return foldinfo.level
  end
  return ffi.C.fold_info(win, lnum + foldinfo.lines - 1).level - 1 -- one less than the foldlevel of the last line in the closed fold
end

local function get_effective_after_foldinfo(win, lnum, foldinfo)
  if foldinfo.lines == 0 then
    return ffi.C.fold_info(win, lnum + 1)
  end
  return ffi.C.fold_info(win, lnum + foldinfo.lines)
end

--- Get the end type of a fold
---
--- @return integer 0 means line does not end a fold of the given level, 1 means line ends a fold of the given level, 2 means line ends a fold of a given level and is the last end for that level
local function get_end_type(win, level, level_start_foldinfo, after_foldinfo)
  if
    level > after_foldinfo.level
    or (level == after_foldinfo.level and after_foldinfo.start > level_start_foldinfo.start)
  then
    if level == level_start_foldinfo.llevel then
      return 2
    end
    return 1
  end
  return 0
end

--- Get the foldinfo of the fold with the given level that contains the given line
---
---@param win win_T window to target
---@param foldinfo foldinfo_T foldinfo of the line in question
---@param level integer level of fold that contains the line in question
---@return foldinfo_T|boolean
local function get_level_start_foldinfo(win, foldinfo, level)
  if level > foldinfo.level then
    return false
  end
  local start_foldinfo = ffi.C.fold_info(win, foldinfo.start)
  if start_foldinfo.level == level or start_foldinfo.llevel == level then
    return start_foldinfo
  end
  return get_level_start_foldinfo(win, ffi.C.fold_info(win, foldinfo.start - 1), level)
end

--- Get the icon for a line corresponding to a specific foldlevel
---   - git graph drawing characters available in terminals that support it:
---     - https://github.com/kovidgoyal/kitty/pull/7681
---     -                                            
---
---@param win win_T window to target
---@param lnum integer line number of the line in question
---@param foldinfo foldinfo_T foldinfo of the line in question
---@param after_foldinfo foldinfo_T foldinfo of the line in question
---@param level integer level of fold that contains the line in question
---@return string
local function get_level_icon(win, lnum, foldinfo, after_foldinfo, level)
  local level_start_foldinfo = get_level_start_foldinfo(win, foldinfo, level)
  local is_closed = level_start_foldinfo.lines > 0
    and get_effective_foldlevel(win, level_start_foldinfo.start, level_start_foldinfo) < level
  local end_type = get_end_type(win, level, level_start_foldinfo, after_foldinfo)

  local icon
  if vim.v.virtnum == 0 then
    if level_start_foldinfo.level == 0 then
      icon = " "
    elseif is_closed then
      icon = ""
    elseif level_start_foldinfo.start == lnum then
      icon = ""
    elseif end_type ~= 0 then
      icon = "╰"
      -- icon = end_type == 2 and "╰" or ""
    else -- in a fold, but not at start or end
      icon = "│"
    end
  else
    icon = (end_type == 2 and after_foldinfo.level == 0) and " " or "│"
  end
  return icon
end

local function add_fold_debug_info(icons, foldinfo, lnum, win)
  table.insert(
    icons,
    " "
      .. foldinfo.start
      .. " "
      .. foldinfo.level
      .. " "
      .. foldinfo.llevel
      .. " "
      .. get_effective_foldlevel(win, lnum, foldinfo)
      .. " - "
  )
end

--==================================================================================================
-- Range functions
--==================================================================================================

--- Check if line is in the range of the current fold or its nested folds
---
local function in_descendant_range(win, foldinfo, cursor_foldinfo)
  if foldinfo.start == cursor_foldinfo.start then
    return true
  elseif foldinfo.level < cursor_foldinfo.level then
    return false
  elseif foldinfo.start < cursor_foldinfo.start then
    return false
  end

  return in_descendant_range(ffi.C.fold_info(win, foldinfo.start - 1), cursor_foldinfo, win)
end

--- Check if line is in the range that will be hidden when fold containing cursorline is closed via `zc`
---
local function in_closefold_range(win, lnum, foldinfo, cursor_foldinfo)
  local cursor_effective_foldlevel = get_effective_foldlevel(win, vim.fn.line("."), cursor_foldinfo)
  local effective_foldlevel = get_effective_foldlevel(win, lnum, foldinfo)
  if (effective_foldlevel == 0) or (cursor_effective_foldlevel == 0) then
    return false
  end

  local effective_start = get_level_start_foldinfo(win, foldinfo, effective_foldlevel).start
  local cursor_effective_start = get_level_start_foldinfo(win, cursor_foldinfo, cursor_effective_foldlevel).start

  -- any line that has the same start as the cursor, with a greater or equal foldlevel will be folded
  if effective_start == cursor_effective_start and effective_foldlevel >= cursor_effective_foldlevel then
    return true
  -- any line with a foldstart before cursor's logically can't be in range
  elseif foldinfo.start < cursor_effective_start then
    return false
  -- any line with a foldstart after cursor's that has a lower or equal foldlevel can't be in range
  elseif effective_foldlevel <= cursor_effective_foldlevel then
    return false
  end

  -- any line with a foldstart after cursor's that has greater foldlevel is only in range if its parent is in range
  return in_closefold_range(win, foldinfo.start - 1, ffi.C.fold_info(win, foldinfo.start - 1), cursor_foldinfo)
end

--==================================================================================================
-- Component
--==================================================================================================

local function on_click(minwid, clicks, button, mods)
  local mousepos = vim.fn.getmousepos() -- screen position of last mouse click
  local screenstring = vim.fn.screenstring(mousepos.screenrow, mousepos.screencol)
  if screenstring == "" then
    vim.cmd(mousepos.line .. "foldopen")
  elseif screenstring == "" then
    vim.cmd(mousepos.line .. "foldclose")
  end
end

---@param max_width integer Maximum width that the folds will take up. Any level higher than the max width will be flattened.
return function(max_width)
  max_width = max_width or 1

  if max_width <= 0 then
    return { "" }
  end

  local win = ffi.C.find_window_by_handle(vim.api.nvim_get_current_win(), error)
  local lnum = vim.v.lnum
  local foldinfo = ffi.C.fold_info(win, lnum)

  if foldinfo.level == 0 and lnum ~= 1 then -- special case: line 1 can't early return since it sets the click handler for all columns
    return { "" }
  end

  local cursor_lnum = vim.fn.line(".")
  local after_foldinfo = get_effective_after_foldinfo(win, lnum, foldinfo)
  local cursor_foldinfo = ffi.C.fold_info(win, cursor_lnum)

  local icons = {}

  -- Insert icons before current foldlevel
  for level = 1, math.min(max_width, foldinfo.level) - 1 do
    table.insert(icons, get_level_icon(win, lnum, foldinfo, after_foldinfo, level))
  end

  -- Insert icon for current foldlevel
  table.insert(icons, get_level_icon(win, lnum, foldinfo, after_foldinfo, foldinfo.level))

  -- Highlight fold that cursor is in
  if in_closefold_range(win, lnum, foldinfo, cursor_foldinfo) then
    local cursor_level = math.min(max_width, get_effective_foldlevel(win, cursor_lnum, cursor_foldinfo))
    if cursor_level > 0 then
      icons[cursor_level] = "%#CursorLineNr#" .. icons[cursor_level] .. "%#LineNr#"
    end
  end

  -- HACK
  -- The click handler of each column is determined by the click handler set for the first line of that column
  -- Therefore, if the first column only contains one icon, the click handler will apply only to the column that
  -- contains that icon, even if other lines have more columns and have a click handler set for them.
  -- Thus, we padd the first line with spaces to fill width that the folds take up, in order for the click
  -- handler to apply to all icons in all rows.
  if lnum == 1 then
    table.insert(icons, string.rep(" ", math.min(max_width, ffi.C.getDeepestNesting(win)) - #icons))
  end

  -- add_fold_debug_info(icons, foldinfo, lnum, win)
  local str = string.format(
    "%s%s%s",
    (lnum == cursor_lnum) and "%#LineNr#" or "", -- force LineNr highlight on cursorline, which has a default highlight, %*, of CursorLineNr
    table.concat(icons),
    "%*"
  )
  return {
    str,
    on_click = on_click,
  } --, { "CursorMoved", "TextChanged", "InsertLeave" }
end
