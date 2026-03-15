vim.api.nvim_create_user_command("CSpellAdd", function(opts)
	local cspell_file = vim.fn.expand("~/.config/cspell/custom.txt")

	local function open_viewer()
		Snacks.terminal("nvim " .. cspell_file)
	end

	local word = opts.args

	if word == "o" then
		open_viewer()
		return
	end

	-- Check if the word already exists in the file
	local file = io.open(cspell_file, "r")
	local word_exists = false

	if file then
		for line in file:lines() do
			if line == word then
				word_exists = true
				break
			end
		end
		file:close()
	end

	-- Append the word if it doesn't exist
	if not word_exists then
		file = io.open(cspell_file, "a")
		if file then
			file:write(word .. "\n")
			file:close()
			vim.notify("Added '" .. word .. "' to cspell dictionary", vim.log.levels.INFO)
		else
			vim.notify("Failed to open cspell file for writing", vim.log.levels.ERROR)
		end
	else
		vim.notify("Word already exists in cspell dictionary", vim.log.levels.INFO)
	end

	open_viewer()
end, {
	nargs = 1,
	desc = "Append word to cspell dictionary and open in floating terminal",
})
