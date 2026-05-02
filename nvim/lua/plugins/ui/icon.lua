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
        ["go.sum"] = {
          icon = "󰟓",
          color = "#ec407a",
          name = "GoSum",
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
          name = "ReadmeCustom",
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
        ["docker-compose"] = {
          icon = "󰡨",
          color = "#0288D1",
          name = "DOCKERCOMPOSE",
        },
        ["nest-cli.json"] = {
          icon = "",
          color = "#ff1744",
          name = "NestCliJson",
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
        zsh = {
          icon = "",
          color = "#FF8A65",
          name = "Zsh",
        },
        sh = {
          icon = "",
          color = "#FF8A65",
          name = "Shell",
        },
        txt = {
          icon = "",
          color = "#2196F3",
          name = "Text",
        },
        yml = {
          icon = "󰈙",
          color = "#F44336",
          name = "Yml",
        },
        yaml = {
          icon = "󰈙",
          color = "#F44336",
          name = "Yaml",
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

          -- Prefer explicit filename matches before extension fallback so
          -- "docker-compose.*" can resolve via "docker-compose".
          local icon, hl = get_icon(name, "", icon_opts)
          if icon then
            return icon, hl
          end

          -- Fallback for dotted filenames: if ".env.example" has no direct match,
          -- retry progressively as ".env", enabling reusable "xxx.*" behavior.
          if type(name) == "string" then
            local prefix = name:match("^(.+)%.[^.]+$")
            while prefix do
              icon, hl = get_icon(prefix, "", icon_opts)
              if icon then
                return icon, hl
              end
              prefix = prefix:match("^(.+)%.[^.]+$")
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
