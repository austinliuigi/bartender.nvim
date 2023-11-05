local lsp_root = {}

function lsp_root.provider()
  local icon

  -- no lsp attached
  if #vim.lsp.get_clients({bufnr = 0}) == 0 then
    icon = ""
  -- lsp attached in single-file mode
  elseif #vim.lsp.buf.list_workspace_folders() == 0 then
    icon = ""
  -- lsp attached to workspace folder
  else
    icon = ""
  end

  return {
    text = icon,
  }
end

return lsp_root
