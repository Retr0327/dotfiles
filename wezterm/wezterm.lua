local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.max_fps = 120
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"

config.font = wezterm.font_with_fallback({
	{
		family = "JetBrainsMono Nerd Font",
		weight = "Medium",
	},
	{
		family = "PingFang TC",
		weight = "Medium",
	},
})
config.font_size = 19

-- Cell adjustments
config.line_height = 1.05
config.cell_width = 1.05

config.window_background_image = wezterm.config_dir .. "/starfield.jpeg"
config.window_background_image_hsb = {
	brightness = 0.08,
}

config.colors = {
	cursor_bg = "#ffffff",
}

config.prefer_egl = true

-- Window size and padding
config.initial_cols = 100
config.initial_rows = 30
config.window_padding = {
	left = 0,
	right = 0,
	top = 5,
	bottom = 00,
}

-- macOS specific settings
config.native_macos_fullscreen_mode = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

return config
