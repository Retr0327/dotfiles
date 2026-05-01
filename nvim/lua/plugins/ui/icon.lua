return {
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      strict = true,
      -- In strict mode, filename and extension overrides are used directly.
      override_by_filename = {
        ["go.mod"] = {
          icon = "󰟓",
          color = "#ec407a",
          name = "GoModule",
        },
        [".gitignore"] = {
          icon = "",
          color = "#e64a19",
          name = "GitIgnore",
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
        ["README.md"] = {
          icon = "",
          color = "#42a5f5",
          name = "README",
        },
        [".sequelizerc"] = {
          icon = "",
          color = "#4fc3f7",
          name = "SEQUELIZE",
        },
        ["Dockerfile"] = {
          icon = "󰡨",
          color = "#0288D1",
          name = "DOCKERFILE",
        },
      },
      override_by_extension = {
        js = {
          icon = "",
          color = "#ffca28",
          name = "Js",
        },
        ts = {
          icon = "",
          color = "#0288d1",
          name = "Ts",
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
        md = {
          icon = "",
          color = "#42a5f5",
          name = "Markdown",
        },
      },
    },
    config = function(_, opts)
      local devicons = require("nvim-web-devicons")
      devicons.setup(opts)
      if not devicons._basename_lookup_patched then
        local get_icon = devicons.get_icon
        devicons.get_icon = function(name, ext, icon_opts)
          if type(name) == "string" and name ~= "" then
            local base = vim.fs.basename(name)
            if base ~= "" then
              name = base
            end
          end
          if (not ext or ext == "") and type(name) == "string" then
            ext = name:match("^.+%.([^.]+)$")
          end
          return get_icon(name, ext, icon_opts)
        end
        devicons._basename_lookup_patched = true
      end
    end,
  },
}
