return {
  cwd      = require("bartender.builtin.components.cwd").provider,
  devicon  = require("bartender.builtin.components.devicon").provider,
  fileformat = require("bartender.builtin.components.fileformat").provider,
  filepath = require("bartender.builtin.components.filepath").provider,
  lsp_root = require("bartender.builtin.components.lsp_root").provider,
  mode     = require("bartender.builtin.components.mode").provider,
  modified = require("bartender.builtin.components.modified").provider,
  navic    = require("bartender.builtin.components.navic").provider,
  readonly = require("bartender.builtin.components.readonly").provider,
}
