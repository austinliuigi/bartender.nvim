--- Path of the current working directory

return function()
  return {
    vim.fn.getcwd():gsub(vim.env.HOME, "~"),
  }, { "DirChanged" }
end
