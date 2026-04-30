local auto_reload_group = vim.api.nvim_create_augroup("auto_reload_files", { clear = true })
local min_check_interval_ms = 1000
local last_check_ms = 0

local function should_skip_checktime()
  if vim.fn.mode() == "c" then
    return true
  end

  if vim.bo.buftype ~= "" then
    return true
  end

  if vim.api.nvim_buf_get_name(0) == "" then
    return true
  end

  return false
end

-- Auto-reload files changed outside of Neovim with lightweight throttling for hold events.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = auto_reload_group,
  pattern = "*",
  callback = function(args)
    if should_skip_checktime() then
      return
    end

    local now = vim.uv.now()
    local force_check = args.event == "FocusGained"
    if not force_check and (now - last_check_ms) < min_check_interval_ms then
      return
    end

    last_check_ms = now
    vim.cmd("checktime")
  end,
})

-- Refresh gitsigns after file reload
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = auto_reload_group,
  pattern = "*",
  callback = function()
    local ok, gitsigns = pcall(require, "gitsigns")
    if ok then
      gitsigns.refresh()
    end
  end,
})
