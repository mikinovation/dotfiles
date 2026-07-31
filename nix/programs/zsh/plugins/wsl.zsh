# WSL2 clipboard configuration
if grep -q microsoft /proc/version; then
  # WSLg exposes a Wayland compositor whose selection is bridged to the Windows
  # clipboard. wl-clipboard talks to it directly, is ~30x faster than going
  # through powershell.exe (25ms vs 734ms), and needs no iconv conversion.
  if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null 2>&1; then
    alias pbcopy="wl-copy --type text/plain"
    alias pbpaste="wl-paste --no-newline --type text/plain"
  else
    # Fallback for WSL without WSLg. clip.exe expects UTF-16LE input.
    alias pbcopy="iconv -f UTF-8 -t UTF-16LE | clip.exe"
    alias pbpaste="powershell.exe -NoProfile -command '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; \$c = Get-Clipboard; if (\$c -ne \$null) { \$c }' | tr -d '\r'"
  fi

  # Locale settings for WSL
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export LANGUAGE=en_US:en
fi
