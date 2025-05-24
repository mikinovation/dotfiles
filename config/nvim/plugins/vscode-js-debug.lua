local vscodeJsDebug = {}

function vscodeJsDebug.config()
	return {
		"microsoft/vscode-js-debug",
		commit = "3ed213faba62916c4d73233bd837a57179b40b2a",
		build = "npm isntall --legacy-peer-deps && npm run compile",
	}
end

return vscodeJsDebug
