local sqlite = {}

function sqlite.config()
	return {
		"kkharji/sqlite.lua",
		init = function()
			-- sqlite.lua probes hardcoded FHS paths (/usr/lib/libsqlite3.so and
			-- friends) which do not exist on NixOS, so ffi.load fails and every
			-- consumer (yanky's ring storage, telescope-frecency) silently breaks.
			-- The neovim wrapper hands us the store path instead;
			-- see nix/programs/neovim/default.nix.
			local clib_path = vim.env.NVIM_SQLITE_CLIB_PATH

			if clib_path and clib_path ~= "" then
				vim.g.sqlite_clib_path = clib_path
			end
		end,
	}
end

return sqlite
