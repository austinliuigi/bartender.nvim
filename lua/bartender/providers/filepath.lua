--- Filepath of buffer

---@param bufnr integer Buffer number
---@param modifier string Modifier string, like in `:h fnamemodify()`
return function(bufnr, modifier, max_chars)
  bufnr = bufnr or 0
  modifier = modifier or ""
  max_chars = math.max(0, max_chars or (vim.api.nvim_win_get_width(0) / 3))

  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), modifier)
  if path == "" then
    path = "---"
  end

  local len = 10
  while vim.fn.strchars(path) > max_chars do
    path = vim.fn.pathshorten(path, len)
    len = len - 1
    if len < 1 then
      break
    end
  end

  return {
    path,
  }, { "BufWinEnter", "WinResized" }
end
