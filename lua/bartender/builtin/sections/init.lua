return {
  cwd        = require("bartender.builtin.sections.cwd").provider,
  file       = require("bartender.builtin.sections.file").provider,
  head       = require("bartender.builtin.sections.head").provider,
  mode       = require("bartender.builtin.sections.mode").provider,
  navic      = require("bartender.builtin.sections.navic").provider,
  partition  = require("bartender.builtin.sections.partition").provider,
  pos        = require("bartender.builtin.sections.pos").provider,
  round_tail = require("bartender.builtin.sections.round_tail").provider,
  sharp_tail = require("bartender.builtin.sections.sharp_tail").provider,
  tabs       = require("bartender.builtin.sections.tabs").provider,
}
