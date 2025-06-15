globals = {
	"vim"
}

exclude_files = {
	"./sandbox/**",
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
