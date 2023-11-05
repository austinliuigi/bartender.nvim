local cwd = {}

--- Path of the current working directory
--
function cwd.provider()
  return {
    text = vim.fn.getcwd():gsub(vim.env.HOME, "~"),
  }, { "DirChanged" }
end


return cwd
