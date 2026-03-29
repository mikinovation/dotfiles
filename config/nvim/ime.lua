-- luacheck: globals vim

-- IME auto-switching on mode change
-- Automatically disables IME when leaving insert mode and restores it when re-entering

local M = {}

local function get_ime_command()
	if vim.fn.executable("fcitx5-remote") == 1 then
		return "fcitx5"
	elseif vim.fn.executable("fcitx-remote") == 1 then
		return "fcitx"
	elseif vim.fn.executable("ibus") == 1 then
		return "ibus"
	elseif vim.fn.executable("im-select") == 1 then
		return "im-select"
	end
	return nil
end

local function disable_ime(ime_type)
	if ime_type == "fcitx5" then
		vim.fn.system("fcitx5-remote -c")
	elseif ime_type == "fcitx" then
		vim.fn.system("fcitx-remote -c")
	elseif ime_type == "ibus" then
		vim.fn.system("ibus engine xkb:us::eng")
	elseif ime_type == "im-select" then
		vim.fn.system("im-select com.apple.keylayout.ABC")
	end
end

local function restore_ime(ime_type, prev_status)
	if not prev_status then
		return
	end

	if ime_type == "fcitx5" then
		if prev_status == "2" then
			vim.fn.system("fcitx5-remote -o")
		end
	elseif ime_type == "fcitx" then
		if prev_status == "2" then
			vim.fn.system("fcitx-remote -o")
		end
	elseif ime_type == "ibus" then
		if prev_status ~= "xkb:us::eng" then
			vim.fn.system("ibus engine " .. prev_status)
		end
	elseif ime_type == "im-select" then
		if prev_status ~= "com.apple.keylayout.ABC" then
			vim.fn.system("im-select " .. prev_status)
		end
	end
end

local function get_ime_status(ime_type)
	if ime_type == "fcitx5" then
		return vim.fn.system("fcitx5-remote"):gsub("%s+", "")
	elseif ime_type == "fcitx" then
		return vim.fn.system("fcitx-remote"):gsub("%s+", "")
	elseif ime_type == "ibus" then
		return vim.fn.system("ibus engine"):gsub("%s+", "")
	elseif ime_type == "im-select" then
		return vim.fn.system("im-select"):gsub("%s+", "")
	end
	return nil
end

function M.setup()
	local ime_type = get_ime_command()
	if not ime_type then
		return
	end

	local ime_status = nil

	local group = vim.api.nvim_create_augroup("IMEControl", { clear = true })

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			ime_status = get_ime_status(ime_type)
			disable_ime(ime_type)
		end,
	})

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			restore_ime(ime_type, ime_status)
		end,
	})
end

return M
