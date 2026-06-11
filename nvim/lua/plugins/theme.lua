return {
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    opts = {
      style = "dark",
      transparent = true,
      italic_comments = false,
      underline_links = true,
      terminal_colors = true,
      group_overrides = {
        Cursor = { fg = "#223E55", bg = "#B5CEA8", bold = true },
      },
    },
    config = function(_, opts)
      require("vscode").setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.rainbow_delimiters = {
        highlight = {
          "RainbowDelimiterYellow",
          "RainbowDelimiterViolet",
          "RainbowDelimiterBlue",
        },
      }
    end,
    config = function()
      local palette = {
        RainbowDelimiterYellow = { fg = "#FFD700", ctermfg = 220 }, -- depth 0
        RainbowDelimiterViolet = { fg = "#DA70D6", ctermfg = 170 }, -- depth 1
        RainbowDelimiterBlue = { fg = "#179FFF", ctermfg = 39 }, -- depth 2
      }

      local function apply_palette()
        for group, opts in pairs(palette) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_rainbow_palette", { clear = true }),
        pattern = "*",
        desc = "Apply VSCode bracket-pair colors to rainbow-delimiters",
        callback = apply_palette,
      })

      apply_palette()
    end,
  },
}
