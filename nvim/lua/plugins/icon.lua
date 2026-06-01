local function expand(spec)
  local out = {}
  for csv, def in pairs(spec) do
    for k in csv:gmatch("[^,%s]+") do
      out[k] = vim.deepcopy(def)
    end
  end
  return out
end

local function with_prefixed_colored_names(icons, prefix)
  local out = vim.deepcopy(icons or {})
  for _, entry in pairs(out) do
    if entry.color and entry.name and entry.name:sub(1, #prefix) ~= prefix then
      entry.name = prefix .. entry.name
    end
  end
  return out
end

local function match_pattern_icon(name, exact_filenames, pattern_icons)
  local base = name
  if type(base) == "string" then
    base = base:match("([^/]+)$") or base
  end

  if type(base) ~= "string" then
    return nil, base
  end

  local lower = base:lower()
  if (exact_filenames or {})[lower] then
    return nil, base
  end

  for _, entry in ipairs(pattern_icons or {}) do
    if lower:match(entry.pattern) then
      return entry, base
    end
  end

  return nil, base
end

local function icon_highlight(entry)
  return entry.name and "DevIcon" .. entry.name
end

local function highlight_colors(group)
  if not group then
    return nil, nil
  end

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or vim.tbl_isempty(hl) then
    return nil, nil
  end

  local color = hl.fg and string.format("#%06x", hl.fg) or nil
  return color, hl.ctermfg
end

local function icon_colors(entry)
  local color, cterm_color = highlight_colors(icon_highlight(entry))
  return color or entry.color, cterm_color or entry.cterm_color
end

return {
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      color_icons = true,
      default = true,
      strict = true,
      override_by_extension = expand({
        json = {
          icon = "",
          color = "#f5c542",
          name = "Json",
        },
        ["js,cjs,mjs"] = {
          icon = "",
          color = "#ffca28",
          name = "Js",
        },
        ["ts,mts,cts"] = {
          icon = "",
          color = "#0288d1",
          name = "Ts",
        },
        md = {
          icon = "󰍔",
          color = "#42a5f5",
          name = "Markdown",
        },
        go = {
          icon = "󰟓",
          color = "#00acc1",
          name = "Go",
        },
        java = {
          icon = "󰅶",
          color = "#F44336",
          name = "Java",
        },
        class = {
          icon = "󰅶",
          color = "#1e88e5",
          name = "JavaClass",
        },
        txt = {
          icon = "",
          color = "#2196F3",
          name = "Text",
        },
        http = {
          icon = "",
          color = "#e53935",
          name = "Request",
        },
        ["zsh,sh,bash"] = {
          icon = "",
          color = "#FF8A65",
          name = "Shell",
        },
        ["yml,yaml"] = {
          icon = "󰈙",
          color = "#F44336",
          name = "Yaml",
        },
        ["tar,zip,gz,tgz,xz,7z,rar"] = {
          icon = "󰗄",
          color = "#afb42b",
          name = "Archive",
        },
        ["csv,xlsx,xls,xlsm"] = {
          icon = "󰈛",
          color = "#8bc34a",
          name = "Spreadsheet",
        },
      }),
      override_by_filename = {
        ["README.md"] = {
          icon = "󰋼",
          color = "#42a5f5",
          name = "Readme",
        },
        ["package.json"] = {
          icon = "󰎙",
          color = "#8bc34a",
          name = "PackageJson",
        },
        ["package-lock.json"] = {
          icon = "󰎙",
          color = "#8bc34a",
          name = "PackageLockJson",
        },
        ["go.mod"] = {
          icon = "󰟓",
          color = "#ec407a",
          name = "GoModule",
        },
        ["go.sum"] = {
          icon = "󰟓",
          color = "#ec407a",
          name = "GoModuleChecksum",
        },
        ["SKILL.md"] = {
          icon = "󰌵",
          color = "#ff8f00",
          name = "AgentSkillMarkdown",
        },
        [".env"] = {
          icon = "",
          name = "Env",
        },
        ["nest-cli.json"] = {
          icon = "",
          color = "#ff1744",
          name = "NestCliJson",
        },
      },
      -- custom field, not part of nvim-web-devicons opts
      match_by_pattern = {
        { pattern = "^.+%.controller%.ts$", icon = "", color = "#3b86cb", name = "NestController" },
        { pattern = "^.+%.service%.ts$", icon = "", color = "#f7cc4f", name = "NestService" },
        { pattern = "^.+%.pipe%.ts$", icon = "", color = "#3b877b", name = "NestPipeline" },
        { pattern = "^.+%.guard%.ts$", icon = "", color = "#5d9e52", name = "NestGuard" },
        { pattern = "^.+%.module%.ts$", icon = "", color = "#d3483e", name = "NestModule" },
        { pattern = "^.+%.middleware%.ts$", icon = "", color = "#5f6bba", name = "NestMiddleware" },
        { pattern = "^.+%.decorator%.ts$", icon = "", color = "#9f4db6", name = "NestDecorator" },
        { pattern = "^.+%.filter%.ts$", icon = "", color = "#ee7950", name = "NestFilter" },
        { pattern = "^.+%.gateway%.ts$", icon = "", color = "#b0b447", name = "NestGateway" },
        { pattern = "^.+%.resolver%.ts$", icon = "", color = "#da4f7a", name = "NestResolver" },
        { pattern = "^.+%.interceptor%.ts$", icon = "", color = "#ee7950", name = "NestInterceptor" },
        { pattern = "^%.env%.", icon = "", color = "#FAF743", cterm_color = "227", name = "Env" },
        {
          pattern = "^docker%-compose.*%.ya?ml$",
          icon = "󰡨",
          color = "#458EE6",
          cterm_color = "68",
          name = "Dockerfile",
        },
        { pattern = "^compose.*%.ya?ml$", icon = "󰡨", color = "#458EE6", cterm_color = "68", name = "Dockerfile" },
        { pattern = "^dockerfile", icon = "󰡨", color = "#458EE6", cterm_color = "68", name = "Dockerfile" },
      },
    },
    config = function(_, opts)
      local devicons = require("nvim-web-devicons")

      local prefix = "Override"
      local extension_icons = with_prefixed_colored_names(opts.override_by_extension, prefix)
      local filename_icons = with_prefixed_colored_names(opts.override_by_filename, prefix)
      local pattern_icons = vim.deepcopy(opts.match_by_pattern or {})
      local setup_opts = vim.deepcopy(opts)

      setup_opts.match_by_pattern = nil
      setup_opts.override_by_extension = extension_icons
      setup_opts.override_by_filename = filename_icons
      devicons.setup(setup_opts)

      local function register_highlights()
        for _, entry in ipairs(pattern_icons) do
          if entry.color and entry.name then
            vim.api.nvim_set_hl(0, "DevIcon" .. entry.name, { fg = entry.color })
          end
        end
      end
      register_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_devicon_highlights", { clear = true }),
        callback = function()
          register_highlights()
          vim.schedule(register_highlights)
        end,
      })

      local exact_filenames = {}
      for k in pairs(filename_icons) do
        exact_filenames[k:lower()] = true
      end

      local state = devicons._custom_pattern_icons
      if not state then
        state = {
          original_get_icon = devicons.get_icon,
          original_get_icon_colors = devicons.get_icon_colors,
        }
        devicons._custom_pattern_icons = state

        devicons.get_icon = function(name, ext, o)
          local entry, base = match_pattern_icon(name, state.exact_filenames, state.pattern_icons)
          if entry then
            return entry.icon, icon_highlight(entry)
          end
          return state.original_get_icon(base or name, ext, o)
        end

        devicons.get_icon_colors = function(name, ext, o)
          local entry, base = match_pattern_icon(name, state.exact_filenames, state.pattern_icons)
          if entry then
            local color, cterm_color = icon_colors(entry)
            return entry.icon, color, cterm_color
          end
          return state.original_get_icon_colors(base or name, ext, o)
        end
      end

      -- exact filename -> custom pattern -> extension/default.
      state.exact_filenames = exact_filenames
      state.pattern_icons = pattern_icons
    end,
  },
}
