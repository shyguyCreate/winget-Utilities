#----------------------------------------------------------
#
#     Author of the script: shyguyCreate
#                Github.com/shyguyCreate
#
#----------------------------------------------------------


#################### Fuctions ############################

#ONLY for debug
function Debug-NumberOfMatches ([array] $logArray)
{
    $Stepping = $Statement_has = $_savepoint = $SAVEPOINT = $ROLLBACK = $RELEASE = $_TABLE = $Reset = $_INDEX = $Setting = 0
    $_arrow_ = $SELECT = $INSERT = $UPDATE = $DELETE = 0

    for ($i = 0; $i -lt $logArray.Length; $i++)
    {
            if ($logArray[$i] -cmatch '^Stepping statement #\d+(-\d+)?$') { $Stepping++ }
        elseif ($logArray[$i] -cmatch '^Statement #\d+(-\d+)? has') { $Statement_has++ }
        elseif ($logArray[$i] -match '^\d+ =>') { $_arrow_++ }
        elseif ($logArray[$i] -match '^SELECT') { $SELECT++ }
        elseif ($logArray[$i] -cmatch '^(\w+ )+savepoint:') { $_savepoint++ }
        elseif ($logArray[$i] -cmatch '^SAVEPOINT') { $SAVEPOINT++ }
        elseif ($logArray[$i] -cmatch '^ROLLBACK') { $ROLLBACK++ }
        elseif ($logArray[$i] -cmatch '^RELEASE') { $RELEASE++ }
        elseif ($logArray[$i] -match '^INSERT') { $INSERT++ }
        elseif ($logArray[$i] -match '^UPDATE') { $UPDATE++ }
        elseif ($logArray[$i] -cmatch '^(\w+ )+TABLE') { $_TABLE++ }
        elseif ($logArray[$i] -cmatch '^Reset statement #\d+(-\d+)?$') { $Reset++ }
        elseif ($logArray[$i] -cmatch '^(\w+ )+INDEX') { $_INDEX++ }
        elseif ($logArray[$i] -match '^DELETE') { $DELETE++ }
        elseif ($logArray[$i] -cmatch '^Setting action:') { $Setting++ }
    }

    Write-Output "
    `r`$Stepping: $Stepping
    `r`$Statement_has: $Statement_has
    `r`$_arrow_: $_arrow_
    `r`$SELECT: $SELECT
    `r`$_savepoint: $_savepoint
    `r`$SAVEPOINT: $SAVEPOINT
    `r`$ROLLBACK: $ROLLBACK
    `r`$RELEASE: $RELEASE
    `r`$INSERT: $INSERT
    `r`$UPDATE: $UPDATE
    `r`$_TABLE: $_TABLE
    `r`$Reset: $Reset
    `r`$_INDEX: $_INDEX
    `r`$DELETE: $DELETE
    `r`$Setting: $Setting
    "
}


function Format-Log ([array] $logArray)
{
    [array] $logArrayReturn = @()

    for ($i = 0; $i -lt $logArray.Length; $i++)
    {
        if ($logArray[$i] -cmatch '^Stepping statement #\d+(-\d+)?$') { continue }
        if ($logArray[$i] -cmatch '^Statement #\d+(-\d+)? has') { continue }
        if ($logArray[$i] -match '^\d+ =>') { continue }
        if ($logArray[$i] -match '^SELECT') { continue }
        if ($logArray[$i] -cmatch '^(\w+ )+savepoint:') { continue }
        if ($logArray[$i] -cmatch '^SAVEPOINT') { continue }
        if ($logArray[$i] -cmatch '^ROLLBACK') { continue }
        if ($logArray[$i] -cmatch '^RELEASE') { continue }
        if ($logArray[$i] -match '^INSERT') { continue }
        if ($logArray[$i] -match '^UPDATE') { continue }
        if ($logArray[$i] -cmatch '^(\w+ )+TABLE') { continue }
        if ($logArray[$i] -cmatch '^Reset statement #\d+(-\d+)?$') { continue }
        if ($logArray[$i] -cmatch '^(\w+ )+INDEX') { continue }
        if ($logArray[$i] -match '^DELETE') { continue }
        if ($logArray[$i] -cmatch '^Setting action:') { continue }

        #Every line that does not match any string will be passed to the file.
        $logArrayReturn += $logArray[$i]
    }
    return $logArrayReturn | Where-Object { $_ -ne '' }
}



# ============================================================================================

################################# Start Main Program #########################################

#Create log file in verbose mode
winget list -s winget --verbose-logs > $null

#Get last created winget log.
$logFile = (Get-Item "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir\WinGet-*" |
            Sort-Object CreationTime | Select-Object -ExpandProperty FullName -Last 1)


#Get log lines only if it starts with a 4 digit number.
#And remove words followed by a hashtag and numbers if exists.
[array] $logContent = Get-Content $logFile |
                      Where-Object { $_ -match '^\d{4}' } |
                      ForEach-Object { $_ -replace '^.{31}((\w+ )+#\d+(-\d+)?: )?','' }


#Save content to file
# logContent | Out-File -FilePath "$logFile.bak"

#Uncomment this line to count the number of matches produced.
# Debug-NumberOfMatches $logContent

#Here many of the lines will be removed or change to make the log file more understandable.
$logContent = Format-Log $logContent

#The file is created or overwritten with the new content from the logContent variable.
Set-Content $logFile -Value $logContent

Write-Host "`nOpening formatted log .txt file.`n"
#Opens the file.
Invoke-Item $logFile


#END of the script
