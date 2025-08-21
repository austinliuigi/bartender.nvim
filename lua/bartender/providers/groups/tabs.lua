local providers = require("bartender.providers")
local utils = require("bartender.utils")

local function tab_component(tabpagenr)
  local hl, sep_hl, icon
  if tabpagenr == vim.fn.tabpagenr() then
    sep_hl = utils.hl_attrs_wrap({ fg = { "TabLineSel", "bg" }, bg = { "TabLineFill", "bg" } })
    hl = "TabLineSel"
    icon = ""
  else
    sep_hl = utils.hl_attrs_wrap({ fg = { "TabLine", "bg" }, bg = { "TabLineFill", "bg" } })
    hl = "TabLine"
    icon = ""
  end

  return {
    { "", hl = sep_hl },
    { string.format(" %s %s ", icon, tabpagenr), hl = hl },
    {
      providers.filepath,
      args = function()
        return {
          vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(vim.api.nvim_list_tabpages()[tabpagenr])),
          ":t",
        }
      end,
      hl = hl,
    },
    { " ", hl = hl },
    { "", hl = sep_hl },
    on_click = function()
      vim.cmd("tabn " .. tabpagenr)
    end,
  }, { "TabEnter" }
end

return function()
  local group = {
    { "    ", hl = utils.hl_attrs_wrap({ fg = { "Normal", "bg" }, bg = { "Special", "fg" } }) },
    { "", hl = "Special" },
  }

  for tabpagenr = 1, vim.fn.tabpagenr("$") do
    table.insert(group, {
      tab_component,
      args = { tabpagenr },
    })
  end

  return group
  -- TODO: Uncomment when TabMoved autocmd exists
  -- , { "TabNew", "TabClosed", "TabMoved" }
end
