# WSL2 clipboard configuration
if grep -q microsoft /proc/version; then
  # Using win32yank from ~/.local/bin
  # Alternative method using PowerShell
  alias pbcopy="clip.exe"
  alias pbpaste="powershell.exe -command 'Get-Clipboard' | tr -d '\r'"

  # Locale settings for WSL
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export LANGUAGE=en_US:en
fi
