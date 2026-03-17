-- Auto-reload files changed outside of Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() == "c" then
      return
    end
    if vim.bo.buftype ~= "" then
      return
    end
    vim.cmd("checktime")
  end,
})

-- Refresh gitsigns after file reload
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    require("gitsigns").refresh()
  end,
})
