#!/bin/bash
# Claude Code notification: Windows toast on WSL, Notification Center on macOS

TITLE="🤖 Claude Code"
MESSAGE="Task completed"

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Ping\"" 2>/dev/null
    ;;
  *)
# PowerShell here-string の終端 "@ は行頭になければならないためインデントしない
powershell.exe -Command "
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

\$APP_ID = 'ClaudeCode'
\$template = @\"
<toast>
    <visual>
        <binding template='ToastText02'>
            <text id='1'>🤖 Claude Code</text>
            <text id='2'>$MESSAGE</text>
        </binding>
    </visual>
    <audio src='ms-winsoundevent:Notification.Default'/>
</toast>
\"@

\$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
\$xml.LoadXml(\$template)
\$toast = New-Object Windows.UI.Notifications.ToastNotification \$xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\$APP_ID).Show(\$toast)
" 2>/dev/null
    ;;
esac

exit 0
