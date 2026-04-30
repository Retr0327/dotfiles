local fileio = require("libs.io")
local cspell_file = vim.fn.fnamemodify(vim.fn.expand("~/.config/cspell/custom.txt"), ":p")
local cache = {
  token = nil,
  words = nil,
}

local function invalidate_cache()
  cache.token = nil
  cache.words = nil
end

local function load_word_set()
  local lines, read_err = fileio.read_lines(cspell_file)
  if read_err then
    return nil, read_err
  end

  local words = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      words[line] = true
    end
  end

  cache.words = words
  cache.token = fileio.mtime_token(cspell_file)
  return words, nil
end

local function get_word_set()
  local current_token = fileio.mtime_token(cspell_file)
  if cache.words and cache.token == current_token then
    return cache.words, nil
  end
  return load_word_set()
end

local function open_viewer()
  fileio.open_in_snacks_terminal(cspell_file)
end

vim.api.nvim_create_user_command("CSpellAdd", function(opts)
  local word = vim.trim(opts.args or "")

  if word == "o" then
    open_viewer()
    return
  end

  if word == "" then
    vim.notify("No word provided for cspell dictionary", vim.log.levels.WARN)
    open_viewer()
    return
  end

  local words, read_err = get_word_set()
  if not words then
    vim.notify(read_err or "Failed to read cspell dictionary", vim.log.levels.ERROR)
    open_viewer()
    return
  end

  if words[word] then
    vim.notify("Word already exists in cspell dictionary", vim.log.levels.INFO)
    open_viewer()
    return
  end

  local ok, write_err = fileio.append_line(cspell_file, word)
  if not ok then
    vim.notify(write_err or "Failed to open cspell file for writing", vim.log.levels.ERROR)
  else
    words[word] = true
    cache.token = fileio.mtime_token(cspell_file)
    vim.notify("Added '" .. word .. "' to cspell dictionary", vim.log.levels.INFO)
  end

  open_viewer()
end, {
  nargs = 1,
  desc = "Append word to cspell dictionary and open in floating terminal",
})

vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
  pattern = cspell_file,
  callback = invalidate_cache,
})
