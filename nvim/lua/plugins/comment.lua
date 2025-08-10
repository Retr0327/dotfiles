return {
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false,
    },
    keys = {
      {
        "<leader>td",
        function()
          require("snacks").picker.todo_comments()
        end,
        desc = "[T]o[D]o",
      },
    },
  },
}
