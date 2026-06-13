return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        -- lua = "string",
        javascript = { "template_string" },
        java = false,
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },
  {
    "axelvc/template-string.nvim",
    opts = {
      remove_template_string = true,
    },
  },
}
