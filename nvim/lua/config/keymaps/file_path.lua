local function get_current_file_path()
  if vim.bo.buftype ~= "" then
    vim.notify("Cannot copy file path: current buffer is not a file", vim.log.levels.WARN)
    return nil
  end

  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    vim.notify("Cannot copy file path: current buffer has no file path", vim.log.levels.WARN)
    return nil
  end

  return vim.fs.normalize(vim.fn.fnamemodify(file_path, ":p"))
end

local function copy_file_path()
  local file_path = get_current_file_path()
  if not file_path then
    return
  end

  vim.fn.setreg("+", file_path)
end

vim.keymap.set("n", "<leader>fp", copy_file_path, { desc = "Copy absolute file path" })
