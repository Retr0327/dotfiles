local function get_range()
  local mode = vim.fn.mode()
  local start_line, end_line
  local is_visual = false

  if mode == "v" or mode == "V" or mode == "\22" then
    is_visual = true
    local line_v = vim.fn.line("v")
    local line_cur = vim.fn.line(".")
    start_line = math.min(line_v, line_cur)
    end_line = math.max(line_v, line_cur)
  else
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  return start_line, end_line, is_visual
end

local function exit_visual_mode()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

local function get_current_file_path()
  if vim.bo.buftype ~= "" then
    vim.notify("Cannot copy line reference: current buffer is not a file", vim.log.levels.WARN)
    return nil
  end

  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    vim.notify("Cannot copy line reference: current buffer has no file path", vim.log.levels.WARN)
    return nil
  end

  return file_path
end

local function format_line_reference(file_path, start_line, end_line)
  if start_line == end_line then
    return string.format("%s:%d", file_path, start_line)
  end

  return string.format("%s:%d-%d", file_path, start_line, end_line)
end

local function copy_line_reference()
  local file_path = get_current_file_path()
  if not file_path then
    return
  end

  local start_line, end_line, is_visual = get_range()
  vim.fn.setreg("+", format_line_reference(file_path, start_line, end_line))

  if is_visual then
    exit_visual_mode()
  end
end

local function copy_line_reference_with_block()
  local file_path = get_current_file_path()
  if not file_path then
    return
  end

  local start_line, end_line, is_visual = get_range()
  local location_ref = format_line_reference(file_path, start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code_content = table.concat(lines, "\n")
  local result = string.format("File: `%s`\n```%s\n%s\n```", location_ref, vim.bo.filetype, code_content)

  vim.fn.setreg("+", result)

  if is_visual then
    exit_visual_mode()
  end
end

vim.keymap.set({ "n", "v" }, "<leader>lr", copy_line_reference, { desc = "Copy absolute line reference" })
vim.keymap.set(
  { "n", "v" },
  "<leader>lR",
  copy_line_reference_with_block,
  { desc = "Copy absolute line reference + block" }
)
