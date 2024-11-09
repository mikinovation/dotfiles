local wezterm = require 'wezterm';

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.80
config.text_background_opacity = 0.80

return config
