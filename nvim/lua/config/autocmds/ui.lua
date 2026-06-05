local M = {}

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

-- Clear background while preserving other fields (like `fg`) to prevent plugin breakage.
function M.clear_float_backgrounds()
  for _, group in ipairs(groups) do
    local ok, def = pcall(vim.api.nvim_get_hl, 0, {
      name = group,
      link = false,
      create = false,
    })

    if ok and def then
      def.bg = nil
      def.ctermbg = nil
      vim.api.nvim_set_hl(0, group, def)
    end
  end
end

local augroup = vim.api.nvim_create_augroup("custom_ui_transparent", {
  clear = true,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  pattern = "*",
  desc = "Keep floating UI backgrounds transparent",
  callback = M.clear_float_backgrounds,
})
