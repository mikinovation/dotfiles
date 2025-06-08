# WSL2 clipboard configuration
if grep -q microsoft /proc/version; then
  # Using win32yank from ~/.local/bin
  # Alternative method using PowerShell
  alias pbcopy="clip.exe"
  alias pbpaste="powershell.exe -command 'Get-Clipboard' | tr -d '\r'"

  # Japanese locale settings for WSL
  export LANG=ja_JP.UTF-8
  export LC_ALL=ja_JP.UTF-8
  export LANGUAGE=ja_JP:ja
fi
