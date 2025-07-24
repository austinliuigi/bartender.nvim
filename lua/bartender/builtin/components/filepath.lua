local filepath = {}

--- Filepath of buffer
--
---@param bufnr integer Buffer number
---@param modifier string Modifier string, like in `:h fnamemodify()`
function filepath.provider(bufnr, modifier)
  bufnr = bufnr or 0
  modifier = modifier or ""

  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), modifier)
  if path == "" then
    path = "???"
  end

  return {
    text = path,
    highlight = {
      bold = true,
    },
  }, { "BufEnter" }
end

return filepath
