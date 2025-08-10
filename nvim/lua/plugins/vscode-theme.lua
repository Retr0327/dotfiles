return {
  "Mofiqul/vscode.nvim",
  config = function()
    local c = require("vscode.colors").get_colors()
    require("vscode").setup({
      transparent = true,
      italic_comments = false,
      underline_links = true,
      disable_nvimtree_bg = true,
      terminal_colors = true,
      group_overrides = {
        Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
      },
    })
    vim.cmd.colorscheme("vscode")

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  end,
}
