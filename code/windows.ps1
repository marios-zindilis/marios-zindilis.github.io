Get-Content hosts | ForEach-Object {echo "0.0.0.0 $_"} | Out-File C:\Windows\System32\drivers\etc\hosts

Echo 'Updated C:\Windows\System32\drivers\etc\hosts'