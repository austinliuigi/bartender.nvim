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
]])
local error = ffi.new("Error")

--- Check if line is in the range of the current fold or its nested folds
---
local function in_descendant_range(foldinfo, cursor_foldinfo, win)
  if foldinfo.start == cursor_foldinfo.start then
    return true
  elseif foldinfo.level < cursor_foldinfo.level then
    return false
  elseif foldinfo.start < cursor_foldinfo.start then
    return false
  end

  return in_descendant_range(ffi.C.fold_info(win, foldinfo.start - 1), cursor_foldinfo, win)
end

local function get_effective_foldlevel(foldinfo, win, lnum)
  if foldinfo.lines == 0 then -- if fold is open
    return foldinfo.level
  end
  return ffi.C.fold_info(win, lnum + foldinfo.lines - 1).level - 1 -- one less than the foldlevel of the last line in the closed fold
end

local function get_effective_foldstart(foldinfo, win)
  if foldinfo.lines == 0 then -- if fold is open
    return foldinfo.start
  end
  return ffi.C.fold_info(win, foldinfo.start - 1).start
end

--- Check if line is in the range that will be hidden when fold containing cursorline is closed
---
local function in_closefold_range(foldinfo, cursor_foldinfo, win, lnum)
  local effective_foldlevel = get_effective_foldlevel(foldinfo, win, lnum)
  local cursor_effective_foldlevel = get_effective_foldlevel(cursor_foldinfo, win, vim.fn.line("."))

  if cursor_effective_foldlevel == 0 then
    return false
  end

  local effective_start = get_effective_foldstart(foldinfo, win)
  local cursor_effective_start = get_effective_foldstart(cursor_foldinfo, win)

  -- any line that has the same foldstart as the cursor, with a greater or equal foldlevel will be folded by a zc
  if
    (
      effective_start == cursor_effective_start
      or effective_start == cursor_foldinfo.start
      or foldinfo.start == cursor_foldinfo.start

    ) and effective_foldlevel >= cursor_effective_foldlevel
  then
    return true
  -- any fold before cursor's effective start logically can't be in range
  elseif foldinfo.start < cursor_foldinfo.start then
    return false
  -- any fold after cursor's effect start that have a lower effective foldlevel can't be in range
  elseif effective_foldlevel <= cursor_effective_foldlevel then
    return false
  end

  -- if in a line in which fold starts after cursor's
  return in_closefold_range(ffi.C.fold_info(win, foldinfo.start - 1), cursor_foldinfo, win, lnum)
end

--- Check if an line that ends a fold is the last (most nested)
local function is_last_end(foldinfo, win)
  local foldinfo_start = ffi.C.fold_info(win, foldinfo.start)
  return foldinfo.llevel == foldinfo_start.llevel
end

local function on_click(minwid, clicks, button, mods)
  local mousepos = vim.fn.getmousepos() -- screen position of last mouse click
  local screenstring = vim.fn.screenstring(mousepos.screenrow, mousepos.screencol)
  if screenstring == "" then
    vim.cmd(mousepos.line .. "foldopen")
  elseif screenstring == "" then
    vim.cmd(mousepos.line .. "foldclose")
  end
end

-- Git graph drawing characters available in terminals that support it:
--   - https://github.com/kovidgoyal/kitty/pull/7681
--   -                                            
return function()
  local icon
  local hl

  local lnum = vim.v.lnum
  local win = ffi.C.find_window_by_handle(vim.api.nvim_get_current_win(), error)
  local foldinfo = ffi.C.fold_info(win, lnum)
  local foldinfo_after = ffi.C.fold_info(win, lnum + 1)
  local start = foldinfo.start
  local is_closed = foldinfo.lines > 0
  local is_end = foldinfo.level > foldinfo_after.level
    or (foldinfo_after.start > foldinfo.start and foldinfo.level == foldinfo_after.level)

  local cursor_foldinfo = ffi.C.fold_info(win, vim.fn.line("."))

  if in_closefold_range(foldinfo, cursor_foldinfo, win, lnum) then
    hl = "CursorLineNr"
  end

  if vim.v.virtnum == 0 then
    if foldinfo.level == 0 then
      icon = " "
    elseif is_closed then
      icon = ""
    elseif start == lnum then
      icon = ""
    elseif is_end then
      if is_last_end(foldinfo, win) then
        icon = "╰"
      else
        icon = "│" -- ""
      end
    else -- in a fold, but not at start or end
      icon = "│"
    end
  else
    if is_end and foldinfo_after.level == 0 then
      icon = " "
    else
      icon = "│"
    end
  end

  -- icon = icon
  --   .. " "
  --   .. foldinfo.start
  --   .. " "
  --   .. get_effective_foldlevel(foldinfo, win, lnum)
  --   .. " - "

  return {
    icon,
    hl = hl,
    on_click = on_click,
  }, { "CursorMoved", "TextChanged", "InsertLeave" }
end
