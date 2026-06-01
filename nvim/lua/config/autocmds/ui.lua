local groups = {
  "Normal",
  "NormalFloat",
  "BlinkCmpMenu",
  "BlinkCmpMenuBorder",
  "BlinkCmpDoc",
  "BlinkCmpDocBorder",
  "BlinkCmpDocSeparator",
  "BlinkCmpSignatureHelp",
  "BlinkCmpSignatureHelpBorder",
}

local function clear_float_backgrounds()
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

vim.api.nvim_create_augroup("custom_ui_transparent", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = "custom_ui_transparent",
  pattern = "*",
  callback = clear_float_backgrounds,
})
