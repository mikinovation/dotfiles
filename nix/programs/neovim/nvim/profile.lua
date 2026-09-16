-- profile.lua
--
-- Nix 側の home.sessionVariables.DOTFILES_PROFILE を lua から参照する。
-- "light" は WSL のようにテキスト編集・設計・要件定義しかしない機体向けで、
-- 実行・デバッグ系のツールチェーンが入っていない前提。
-- 環境変数が無いとき（CI のスモークテストなど）は full 扱いにして、
-- 従来どおり全プラグインを読み込む。

local M = {}

function M.name()
	return os.getenv("DOTFILES_PROFILE") or "full"
end

function M.is_full()
	return M.name() ~= "light"
end

return M
