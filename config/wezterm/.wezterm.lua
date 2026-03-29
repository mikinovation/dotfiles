local wezterm = require 'wezterm';

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Tokyo Night"

config.use_ime = true
config.ime_preedit_rendering = "Builtin"

return config
