return {
  "tpope/vim-surround",
  dependencies = { "folke/snacks.nvim" },
  init = function()
    vim.keymap.set("n", "ysiwg", function()
      vim.cmd("normal! yiw")
      local word = vim.fn.getreg('"')

      require("snacks").input({
        prompt = "Type: ",
        default = "",
        icon = " ",
        win = {
          style = "input",
          position = "float",
          relative = "editor",
          width = 60,
          height = 1,
          row = math.floor((vim.o.lines - 10) / 2),
          col = math.floor((vim.o.columns - 60) / 2),
          border = "rounded",
        },
      }, function(value)
        if value and value ~= "" then
          local result = value .. "<" .. word .. ">"
          vim.cmd("normal! ciw")
          vim.api.nvim_put({ result }, "c", false, true)
        end
      end)
    end)
  end,
}
