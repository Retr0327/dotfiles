return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    use_default_keymaps = false,
  },
  keys = {
    {
      "<leader>js",
      "<cmd>TSJToggle<CR>",
      desc = "Toggle Join/Split",
    },
    {
      "<leader>jo",
      "<cmd>TSJJoin<CR>",
      desc = "Join",
    },
    {
      "<leader>sp",
      "<cmd>TSJSplit<CR>",
      desc = "Split",
    },
  },
}
