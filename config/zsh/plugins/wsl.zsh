# WSL2 clipboard configuration
if grep -q microsoft /proc/version; then
  # Using win32yank from ~/.local/bin
  # Alternative method using PowerShell
  alias pbcopy="clip.exe"
  alias pbpaste="powershell.exe -command 'Get-Clipboard' | tr -d '\r'"
fi