local M = {}

---Return a stable mtime token for path, or nil when unavailable.
---@param path string
---@return string|nil
function M.mtime_token(path)
  local stat = vim.uv.fs_stat(path)
  if not stat or not stat.mtime then
    return nil
  end
  local sec = stat.mtime.sec or 0
  local nsec = stat.mtime.nsec or 0
  return string.format("%d:%d", sec, nsec)
end

---@param path string
---@return string[]|nil, string|nil
function M.read_lines(path)
  local file = io.open(path, "r")
  if not file then
    if not vim.uv.fs_stat(path) then
      return {}, nil
    end
    return nil, "Unable to open file for reading"
  end

  local lines = {}
  for line in file:lines() do
    lines[#lines + 1] = line
  end
  file:close()

  return lines, nil
end

---@param path string
---@param line string
---@return boolean, string|nil
function M.append_line(path, line)
  local file = io.open(path, "a")
  if not file then
    return false, "Unable to open file for writing"
  end

  file:write(line .. "\n")
  file:close()
  return true, nil
end

---@param path string
function M.open_in_snacks_terminal(path)
  local ok, snacks = pcall(require, "snacks")
  if ok then
    snacks.terminal("nvim " .. vim.fn.fnameescape(path))
    return
  end

  vim.notify("snacks.nvim is not available; opening file in current window", vim.log.levels.WARN)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

return M
