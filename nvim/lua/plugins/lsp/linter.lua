return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      -- javascript = { "eslint_d" }, -- Use eslint language server instead
      -- typescript = { "eslint_d" }, -- Use eslint language server instead
      -- javascriptreact = { "eslint_d" }, -- Use eslint language server instead
      -- typescriptreact = { "eslint_d" }, -- Use eslint language server instead
      -- python = { "ruff" }, -- Use ruff language server instead
      dockerfile = { "hadolint" },
      go = { "golangcilint" },
      sh = { "shellcheck" },
      markdown = { "markdownlint-cli2" },
      ["*"] = { "cspell" },
    },
    ---@type table<string, table>
    linters = {
      shellcheck = {
        condition = function(ctx)
          -- Skip shellcheck for .env files
          if ctx.filename:match("%.env") or ctx.filename:match("%.env%.[%w_.-]+") then
            return false
          end
          return true
        end,
      },
    },
    default_severity = {
      ["error"] = vim.diagnostic.severity.WARN,
      ["warning"] = vim.diagnostic.severity.WARN,
      ["information"] = vim.diagnostic.severity.INFO,
      ["hint"] = vim.diagnostic.severity.HINT,
    },
  },
  config = function(_, opts)
    local M = {}
    local lint = require("lint")
    local missing_linter_warnings = {}
    local base_names_cache = {}
    local buffer_names_cache = {}

    local function list_copy(list)
      return vim.list_extend({}, list or {})
    end

    local function dedupe(list)
      local seen = {}
      local out = {}
      for _, name in ipairs(list) do
        if not seen[name] then
          seen[name] = true
          out[#out + 1] = name
        end
      end
      return out
    end

    local function ensure_arg(list, value)
      for _, arg in ipairs(list) do
        if arg == value then
          return
        end
      end
      list[#list + 1] = value
    end

    for name, linter in pairs(opts.linters) do
      if type(linter) == "table" and type(lint.linters[name]) == "table" then
        lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        if type(linter.prepend_args) == "table" then
          lint.linters[name].args = lint.linters[name].args or {}
          vim.list_extend(lint.linters[name].args, linter.prepend_args)
        end
      else
        lint.linters[name] = linter
      end
    end

    lint.linters_by_ft = opts.linters_by_ft

    if lint.linters.cspell and type(lint.linters.cspell.args) == "table" then
      ensure_arg(lint.linters.cspell.args, "-c")
      ensure_arg(lint.linters.cspell.args, "~/.config/cspell/cspell.yml")
    end

    function M.debounce(ms, fn)
      local timer = vim.uv.new_timer()
      local unpack_args = table.unpack or unpack
      return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
          timer:stop()
          vim.schedule_wrap(fn)(unpack_args(argv))
        end)
      end
    end

    local function resolve_base_linters(filetype)
      local cached = base_names_cache[filetype]
      if cached then
        return list_copy(cached)
      end

      local names = list_copy(lint._resolve_linter_by_ft(filetype))

      if #names == 0 then
        vim.list_extend(names, lint.linters_by_ft["_"] or {})
      end

      vim.list_extend(names, lint.linters_by_ft["*"] or {})
      names = dedupe(names)
      base_names_cache[filetype] = names
      return list_copy(names)
    end

    local function resolve_buffer_linters(bufnr)
      local filetype = vim.bo[bufnr].filetype
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local cached = buffer_names_cache[bufnr]
      if cached and cached.filetype == filetype and cached.filename == filename then
        return cached.names
      end

      local names = resolve_base_linters(filetype)
      local ctx = { filename = filename }
      ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

      names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        if not linter then
          if not missing_linter_warnings[name] then
            missing_linter_warnings[name] = true
            vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
          end
        end

        return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
      end, names)

      buffer_names_cache[bufnr] = {
        filetype = filetype,
        filename = filename,
        names = names,
      }

      return names
    end

    function M.lint()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
        return
      end

      local names = resolve_buffer_linters(bufnr)
      if #names > 0 then
        lint.try_lint(names)
      end
    end

    local linter_group = vim.api.nvim_create_augroup("linter", { clear = true })

    vim.api.nvim_create_autocmd(opts.events, {
      group = linter_group,
      callback = M.debounce(100, M.lint),
    })

    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
      group = linter_group,
      callback = function(event)
        buffer_names_cache[event.buf] = nil
      end,
    })

    vim.keymap.set("n", "<leader>lt", M.lint, { desc = "Linting" })
  end,
}
