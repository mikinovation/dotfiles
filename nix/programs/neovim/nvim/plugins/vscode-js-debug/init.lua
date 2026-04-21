local vscodeJsDebug = {}

function vscodeJsDebug.config()
	return {
		"microsoft/vscode-js-debug",
		build = "npm isntall --legacy-peer-deps && npm run compile",
	}
end

return vscodeJsDebug
