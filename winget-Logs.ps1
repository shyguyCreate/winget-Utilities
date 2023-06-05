#----------------------------------------------------------
#
#     Author of the script: shyguyCreate
#                Github.com/shyguyCreate
#
#----------------------------------------------------------


#Create log file in verbose mode
winget list -s winget --verbose-logs > $null

#Get last created winget log.
$logFile = (Get-Item "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir\WinGet-*" |
            Sort-Object CreationTime | Select-Object -ExpandProperty FullName -Last 1)


#Get log lines only if it has date and it is not [SQL ].
#And remove time and [XXXX] at the beggining of each line.
Get-Content $logFile |
Where-Object { $_ -match '^.{24}\[(?!SQL)' } |
ForEach-Object { $_ -replace '^.{31}','' } |
Out-File -FilePath $logFile


Write-Host "`nOpening formatted .log file.`n"
#Opens the file.
Invoke-Item $logFile


#END of the script
