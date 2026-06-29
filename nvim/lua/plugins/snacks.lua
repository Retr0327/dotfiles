return {
  "folke/snacks.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {
      enabled = true,
      size = 1.5 * 1024 * 1024,
    },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
⣿⣿⣿⣿⣿⣿⠟⠁⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡏⠂⠂⠂⠂⢙⠛⠙⠛⠻⢿⠟⠁⠂⠂⠸⣿⣿⣿
⣿⣿⣿⡿⠟⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⠂⣿⣿⣿
⣿⡿⢋⣴⣤⣀⣀⣀⣀⣠⣤⣾⣷⣤⣀⠂⠂⠂⠂⠂⠂⢿⣿⣿
⣿⢁⣿⣿⣿⣿⣿⣿⣯⣽⣿⣿⣿⣿⣟⣿⣶⣦⣤⣤⣤⣦⠹⣿
⡇⣼⣿⣿⣿⣿⣿⢋⣭⠹⣿⣿⣿⣿⠟⡛⢿⣿⣿⣿⣿⣿⣇⢸
⠁⣿⣿⡟⡛⠛⢿⣄⣂⣴⣿⣿⣿⣿⡀⠉⢠⣿⣿⣿⣿⣿⣿⠂
⡇⢻⣿⣷⣿⣿⣾⣿⣿⣿⣙⠁⠛⣻⣿⣿⣣⣃⢉⢹⣿⣿⡟⢸
⣿⡌⢻⣿⣿⣿⣿⣿⣿⣿⣿⣍⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢁⣾
⣿⡘⠦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣡⣾⣿
        ]],
      },
    },
    explorer = {
      enabled = true,
      replace_netrw = true,
    },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = true,
      ui_select = true,
      actions = {
        copy_path = function(picker)
          local paths = {}

          for _, item in ipairs(picker:selected({ fallback = true })) do
            local path = Snacks.picker.util.path(item)
            if path then
              paths[#paths + 1] = path
            end
          end

          if #paths == 0 then
            return
          end

          vim.fn.setreg("+", table.concat(paths, "\n"))
        end,
        explorer_yank_selected = function(picker)
          local paths = {}

          for _, item in ipairs(picker:selected()) do
            local path = Snacks.picker.util.path(item)
            if path then
              paths[#paths + 1] = path
            end
          end

          if #paths == 0 then
            return
          end

          vim.fn.setreg(vim.v.register, table.concat(paths, "\n"), "l")
          picker.list:set_selected()
          Snacks.notify.info("files/folders yanked")
        end,
        explorer_paste_files_or_dirs = function(picker)
          local uv = vim.uv or vim.loop
          local files = vim.split(vim.fn.getreg(vim.v.register) or "", "\n", { plain = true })

          files = vim.tbl_filter(function(file)
            return file ~= "" and uv.fs_stat(file) ~= nil
          end, files)

          if #files == 0 then
            return
          end

          local dir = picker:dir()
          Snacks.picker.util.copy(files, dir)

          local Tree = require("snacks.explorer.tree")
          Tree:refresh(dir)
          Tree:open(dir)
          require("snacks.explorer.actions").update(picker, { target = dir })
        end,
      },
      sources = {
        explorer = {
          layout = {
            cycle = false,
          },
          live = true,
          hidden = true, -- for hidden file
          ignored = true, -- for .gitignore files
          toggles = {
            hidden = false, -- dont show h mark
            ignored = false, -- dont show i mark
          },
          diagnostics = false, -- do not show diagnostics in explorer
          diagnostics_open = false,
          win = {
            list = {
              keys = {
                ["y"] = { "explorer_yank_selected", mode = { "n" }, desc = "Yank selected files/folders" },
                ["p"] = { "explorer_paste_files_or_dirs", desc = "Paste files/folders" },
                ["<leader>fp"] = { "copy_path", mode = { "n" }, desc = "Copy absolute path" },
              },
            },
          },
        },
      },
      icons = {
        git = {
          modified = "M",
          untracked = "U",
        },
      },
    },
    image = { enabled = true },
    notifier = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    terminal = {
      win = {
        position = "float",
        border = "rounded",
        style = "minimal",
        backdrop = 60,
        height = 0.9,
        width = 0.9,
        zindex = 50,
      },
    },
    scope = { enabled = true },
    lazygit = { configure = vim.fn.executable("lazygit") == 1 },
  },
  keys = {
    -- search
    {
      "<leader>sf",
      function()
        require("snacks").picker.files()
      end,
      desc = "[S]earch [F]iles",
    },
    {
      "<leader>sg",
      function()
        require("snacks").picker.git_files()
      end,
      desc = "[S]earch [G]it Files",
    },
    {
      "<leader>sr",
      function()
        require("snacks").picker.recent()
      end,
      desc = "[S]earch [R]ecent",
    },
    {
      "<leader>sw",
      function()
        require("snacks").picker.grep()
      end,
      desc = "[S]earch [W]ord",
    },
    {
      "<leader>sc",
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "[S]earch [C]urrent Word",
      mode = { "n", "x" },
    },
    {
      "<leader>sb",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "[S]earch [B]uffers",
    },
    {

      "<leader>sC",
      function()
        require("snacks").picker.highlights({ pattern = "hl_group:^Snacks" })
      end,
      desc = "[S]earch [C]olor",
    },
    {
      "<leader>sn",
      function()
        require("snacks").picker.notifications()
      end,
      desc = "[S]earch [N]otification History",
    },
    {
      "<leader>sT",
      function()
        require("snacks").picker.diagnostics()
      end,
      desc = "[S]earch [T]roubles",
    },
    {
      "<leader>st",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "[S]earch Current [T]rouble",
    },
    {
      "<leader>sd",
      function()
        require("snacks").picker.git_diff()
      end,
      desc = "[S]earch [D]iff Files",
    },
    -- LSP
    {
      "gd",
      function()
        require("snacks").picker.lsp_definitions()
      end,
      desc = "[G]oto [D]efinition",
    },
    {
      "gD",
      function()
        require("snacks").picker.lsp_declarations()
      end,
      desc = "[G]oto [D]eclaration",
    },
    {
      "gr",
      function()
        require("snacks").picker.lsp_references()
      end,
      nowait = true,
      desc = "[G]oto [R]eferences",
    },
    {
      "gi",
      function()
        require("snacks").picker.lsp_implementations()
      end,
      desc = "[G]oto [I]mplementation",
    },
    {
      "gt",
      function()
        require("snacks").picker.lsp_type_definitions()
      end,
      desc = "Goto [T]ype Definition",
    },
    {
      "<leader>ss",
      function()
        require("snacks").picker.lsp_symbols()
      end,
      desc = "[S]earch LSP [S]ymbols",
    },
    {
      "<leader>sS",
      function()
        require("snacks").picker.lsp_workspace_symbols()
      end,
      desc = "[S]earch LSP Workspace [S]ymbols",
    },
    {
      "<leader>sk",
      function()
        require("snacks").picker.keymaps()
      end,
      desc = "[S]earch [K]eymaps",
    },
    {
      "<leader>e",
      function()
        local snacks = require("snacks")
        local existing = snacks.picker.get({ source = "explorer" })[1]
        if existing then
          vim.g._explorer_last_cwd = existing:cwd()
          existing:close()
        else
          snacks.explorer({ cwd = vim.g._explorer_last_cwd })
        end
      end,
      desc = "[E]xplorer",
    },
    {
      "<leader>T",
      function()
        require("snacks").terminal()
      end,
      desc = "Terminal",
    },
    {
      "<leader>u",
      function()
        require("snacks").picker.undo()
      end,
      desc = "[U]ndo History",
    },
    {
      "<leader>rf",
      function()
        require("snacks").rename.rename_file()
      end,
      desc = "[R]ename [F]ile",
    },
    {
      "<leader>gg",
      function()
        require("snacks").lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "]]",
      function()
        require("snacks").words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        require("snacks").words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },
    {
      "<leader>q",
      function()
        require("snacks").bufdelete()
      end,
      desc = "Delete Buffer",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#50fa7b" })
        vim.api.nvim_set_hl(0, "SnacksPickerGitStatusModified", { fg = "#FFE066" })
      end,
    })
  end,
}
