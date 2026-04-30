local M = {}

local function to_hex(color)
  if type(color) ~= "number" then
    return nil
  end
  return string.format("#%06x", color)
end

local function get_hl_color(group, field)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or type(hl) ~= "table" then
    return nil
  end
  return to_hex(hl[field])
end

local function pick_color(...)
  for i = 1, select("#", ...) do
    local color = select(i, ...)
    if color and color ~= "NONE" then
      return color
    end
  end
  return nil
end

local function get_vscode_colors()
  local colors_name = (vim.g.colors_name or ""):lower()
  if colors_name ~= "vscode" then
    return nil
  end

  local ok, colors = pcall(function()
    return require("vscode.colors").get_colors()
  end)
  if not ok then
    return nil
  end
  return colors
end

function M.apply()
  local vscode_colors = get_vscode_colors()

  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#585b70", bold = false })
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#cdd6f4", bold = true })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#585b70", bold = false })
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

  vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#50fa7b" })
  vim.api.nvim_set_hl(0, "SnacksPickerGitStatusModified", { fg = "#FFE066" })
  local tree_fg = (vscode_colors and vscode_colors.vscLineNumber) or get_hl_color("NonText", "fg") or "#5a5a5a"
  local split_fg = (vscode_colors and vscode_colors.vscSplitDark) or tree_fg
  local selected_fg = (vscode_colors and vscode_colors.vscBlue) or get_hl_color("Special", "fg") or "#569cd6"

  vim.api.nvim_set_hl(0, "SnacksPickerTree", { fg = tree_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = tree_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerUnselected", { fg = tree_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerSelected", { fg = selected_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerListBorder", { fg = split_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksWinSeparator", { fg = split_fg, bg = "NONE" })

  local menu_fg =
    pick_color(get_hl_color("Pmenu", "fg"), get_hl_color("NormalFloat", "fg"), get_hl_color("Normal", "fg"))
  if vscode_colors then
    menu_fg = menu_fg or vscode_colors.vscPopupFront or vscode_colors.vscFront
  end
  menu_fg = menu_fg or "#d4d4d4"

  local border_fg = pick_color(get_hl_color("FloatBorder", "fg"), get_hl_color("Pmenu", "fg"), menu_fg)
  local selection_bg = pick_color(get_hl_color("PmenuSel", "bg"), get_hl_color("Visual", "bg"))
  if vscode_colors then
    selection_bg = vscode_colors.vscPopupHighlightBlue or selection_bg
  end
  local selection_fg = pick_color(get_hl_color("PmenuSel", "fg"), menu_fg)

  vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = menu_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = border_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { fg = selection_fg, bg = selection_bg })
  vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = menu_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = menu_fg, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "BlinkCmpLabelDetail", { fg = menu_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", { fg = menu_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "BlinkCmpSource", { fg = menu_fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "BlinkCmpKindCopilot", { fg = "#6CC644" })
end

local ui_group = vim.api.nvim_create_augroup("user_ui_highlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = ui_group,
  callback = M.apply,
})

M.apply()

return M
