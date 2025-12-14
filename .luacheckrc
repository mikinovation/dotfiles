globals = {
	"vim"
}

exclude_files = {
	"./sandbox/**",
	"./.luarocks/**",
	"./result/**",
}

files["**/*_spec.lua"] = {
	globals = {
		"describe",
		"it",
		"before_each",
		"after_each",
		"setup",
		"teardown",
		"pending",
		"spy",
		"stub",
		"mock",
		"assert",
	}
}
