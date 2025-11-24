#!/bin/bash
# Claude Code awaiting input notification to Windows

MESSAGE="Awaiting your input"

# Send Windows toast notification via PowerShell
powershell.exe -Command "
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

\$APP_ID = 'ClaudeCode'
\$template = @\"
<toast>
    <visual>
        <binding template='ToastText02'>
            <text id='1'>⏸️ Claude Code</text>
            <text id='2'>$MESSAGE</text>
        </binding>
    </visual>
    <audio src='ms-winsoundevent:Notification.IM'/>
</toast>
\"@

\$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
\$xml.LoadXml(\$template)
\$toast = New-Object Windows.UI.Notifications.ToastNotification \$xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\$APP_ID).Show(\$toast)
" 2>/dev/null

exit 0
