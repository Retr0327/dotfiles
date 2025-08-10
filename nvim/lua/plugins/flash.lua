return {
	-- "folke/flash.nvim",
	-- opts = {
	-- 	-- I don't want aiorx as options when in flash, not sure why, but I don't
	-- 	-- labels = "asdfghjklqwertyuiopzxcvbnm",
	-- 	labels = "fghjklqwetyupzcvbnm",
	-- 	search = {
	-- 		-- If mode is set to the default "exact" if you mistype a word, it will
	-- 		-- exit flash, and if then you type "i" for example, you will start
	-- 		-- inserting text and fuck up your file outside
	-- 		--
	-- 		-- Search for me adds a protection layer, so if you mistype a word, it
	-- 		-- doesn't exit
	-- 		mode = "search",
	-- 	},
	-- 	modes = {
	-- 		char = {
	-- 			-- f, t, F, T motions:
	-- 			-- After typing f{char} or F{char}, you can repeat the motion with f or go to the previous match with F to undo a jump.
	-- 			-- Similarly, after typing t{char} or T{char}, you can repeat the motion with t or go to the previous match with T.
	-- 			-- You can also go to the next match with ; or previous match with ,
	-- 			-- Any highlights clear automatically when moving, changing buffers, or pressing <esc>.
	-- 			--
	-- 			-- Useful if you do `vtf` or `vff` and then keep pressing f to jump to
	-- 			-- the next `f`s
	-- 			enabled = true,
	-- 		},
	-- 	},
	-- },
	-- config = function()
	-- 	-- Override the `flash.jump` function to detect start and end
	-- 	local flash = require("flash")
	-- 	local original_jump = flash.jump
	--
	-- 	flash.jump = function(opts)
	-- 		vim.api.nvim_exec_autocmds("User", { pattern = "FlashJumpStart" })
	-- 		-- print("flash.nvim enter")
	--
	-- 		original_jump(opts)
	--
	-- 		vim.api.nvim_exec_autocmds("User", { pattern = "FlashJumpEnd" })
	-- 		-- print("flash.nvim leave")
	-- 	end
	-- end,
	-- "folke/flash.nvim",
	-- event = "VeryLazy",
	-- enabled = false,
	-- ---@type Flash.Config
	-- opts = {},
	--  -- stylua: ignore
	--  keys = {
	--    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
	--    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
	--    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
	--    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
	--    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
	--  },
	"folke/flash.nvim",
	optional = true,
	specs = {
		{
			"folke/snacks.nvim",
			opts = {
				picker = {
					win = {
						input = {
							keys = {
								-- ["<leader>s"] = { "flash", mode = { "n", "i" } },
								["F"] = { "flash" },
							},
						},
					},
					actions = {
						flash = function(picker)
							require("flash").jump({
								pattern = "^",
								label = { after = { 0, 0 } },
								search = {
									mode = "search",
									exclude = {
										function(win)
											return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
												~= "snacks_picker_list"
										end,
									},
								},
								action = function(match)
									local idx = picker.list:row2idx(match.pos[1])
									picker.list:_move(idx, true, true)
								end,
							})
						end,
					},
				},
			},
		},
	},
}
