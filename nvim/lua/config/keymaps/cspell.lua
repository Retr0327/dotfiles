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
