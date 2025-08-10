return {
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
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
        ["go.mod"] = {
          icon = "󰟓",
          color = "#ec407a",
          name = "GoModule",
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
          icon = "󰋼",
          color = "#42a5f5",
          name = "README",
        },
        [".sequelizerc"] = {
          icon = "",
          color = "#4fc3f7",
          name = "SEQUELIZE",
        },
        ["Dockerfile"] = {
          icon = "",
          color = "#0288D1",
          name = "DOCKERFILE",
        },
      },
    },
  },
}
