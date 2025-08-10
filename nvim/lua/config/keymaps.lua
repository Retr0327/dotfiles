vim.g.mapleader = " "
vim.g.maplocalleader = "  "

-- move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- tj: Toggle hlsearch if it's on, otherwise just do "enter"
vim.keymap.set("n", "<CR>", function()
  if vim.v.hlsearch == 1 then
    vim.cmd.nohl()
    return ""
  else
    return "k<CR>"
  end
end, { expr = true })

vim.keymap.set("n", "<leader>as", function()
  local word = vim.fn.expand("<cword>")
  if word == "" or word:match("^%s*$") then
    vim.ui.input({
      prompt = "Enter word to add to cspell: ",
    }, function(input)
      if input and input ~= "" then
        vim.cmd("CSpellAdd " .. input)
      end
    end)
  else
    vim.cmd("CSpellAdd " .. word)
  end
end, { desc = "Add CSpell" })

vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Make splits equal size" })

vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Make splits equal size" })

vim.keymap.set("n", "<leader>su", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>wd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
