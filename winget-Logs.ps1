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
    #Debug variables
    $Stepping_statement = 0
    $Statement_has = 0
    $_savepoint = 0
    $SAVEPOINT = 0
    $ROLLBACK = 0
    $RELEASE = 0
    $_TABLE = 0
    $Reset_statement = 0
    $_INDEX = 0
    $Setting_action = 0
    $_arrow_ = 0
    
    $SELECT_rowid = 0
    $SELECT_other = 0
    $INSERT = 0
    $UPDATE = 0
    $DELETE = 0
    $insert_replace = 0
    $select_value = 0

    #Here the matches will be count.
    for ($i = 0; $i -lt $logArray.Length; $i++)
    {
            if ($logArray[$i] -cmatch '^Stepping statement #\d+(-\d+)?$') {  $Stepping_statement++; }
        elseif ($logArray[$i] -cmatch '^Statement #\d+(-\d+)? has') {  $Statement_has++; }
        elseif ($logArray[$i] -cmatch '^(\w+ )+savepoint:') {  $_savepoint++; }
        elseif ($logArray[$i] -cmatch '^SAVEPOINT') {  $SAVEPOINT++; }
        elseif ($logArray[$i] -cmatch '^ROLLBACK') {  $ROLLBACK++; }
        elseif ($logArray[$i] -cmatch '^RELEASE') {  $RELEASE++; }
        elseif ($logArray[$i] -cmatch '^(\w+ )+TABLE') {  $_TABLE++; }
        elseif ($logArray[$i] -cmatch '^Reset statement #\d+(-\d+)?$') {  $Reset_statement++; }
        elseif ($logArray[$i] -cmatch '^(\w+ )+INDEX') {  $_INDEX++; }
        elseif ($logArray[$i] -cmatch '^Setting action:') {  $Setting_action++; }

        elseif ($logArray[$i] -cmatch '^\d+ =>') {  $_arrow_++ }
        elseif ($logArray[$i] -cmatch '^SELECT \[rowid\]') {  $SELECT_rowid++ }
        elseif ($logArray[$i] -cmatch '^SELECT (\[(?!rowid)|COUNT)') {  $SELECT_other++ }
        elseif ($logArray[$i] -cmatch '^INSERT') {  $INSERT++ }
        elseif ($logArray[$i] -cmatch '^UPDATE') {  $UPDATE++ }
        elseif ($logArray[$i] -cmatch '^DELETE') {  $DELETE++ }
        elseif ($logArray[$i] -cmatch '^insert or replace') {  $insert_replace++ }
        elseif ($logArray[$i] -cmatch '^select \[value\]') {  $select_value++ }
    }

    Write-Output "
    `r`$Stepping_statement: $Stepping_statement
    `r`$Statement_has: $Statement_has
    `r`$_savepoint: $_savepoint
    `r`$SAVEPOINT: $SAVEPOINT
    `r`$ROLLBACK: $ROLLBACK
    `r`$RELEASE: $RELEASE
    `r`$_TABLE: $_TABLE
    `r`$Reset_statement: $Reset_statement
    `r`$_INDEX: $_INDEX
    `r`$Setting_action: $Setting_action

    `r`$_arrow_: $_arrow_
    `r`$SELECT_rowid: $SELECT_rowid
    `r`$SELECT_other: $SELECT_other
    `r`$INSERT: $INSERT
    `r`$insert_replace: $insert_replace
    `r`$UPDATE: $UPDATE
    `r`$DELETE: $DELETE
    `r`$select_value: $select_value
    "
}


function Format-Log ([array] $logArray)
{
    [array] $logArrayReturn = @()

    #Foreach line inside the array.
    for ($i = 0; $i -lt $logArray.Length; $i++)
    {
        #Here a lot of extra stuff that doesn't help to understand what is happening (in my consideration)
        #will be left outside of the final file.
        if ($logArray[$i] -cmatch '^Stepping statement #\d+(-\d+)?$') { continue; }
        if ($logArray[$i] -cmatch '^Statement #\d+(-\d+)? has') { continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+savepoint:') { continue; }
        if ($logArray[$i] -cmatch '^SAVEPOINT') { continue; }
        if ($logArray[$i] -cmatch '^ROLLBACK') { continue; }
        if ($logArray[$i] -cmatch '^RELEASE') { continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+TABLE') { continue; }
        if ($logArray[$i] -cmatch '^Reset statement #\d+(-\d+)?$') { continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+INDEX') { continue; }
        if ($logArray[$i] -cmatch '^Setting action:') { continue; }

        #Here is the fun part where a lot of data will not get to the final file, some will be joined with another line
        #to generate less lines overall and some will be replaced by shorted version from their original lines.
        #Comment lines at your consideration.
        if ($logArray[$i] -cmatch '^\d+ =>') { continue; }
        if ($logArray[$i] -cmatch '^SELECT \[rowid\]') { $logArrayReturn += $logArray[$i] -replace '^SELECT.+WHERE (\[\w+\]).+',"`$1 $($logArray[($i+1)] -replace '^\d+ =>','=')"; continue; }
        if ($logArray[$i] -cmatch '^SELECT (\[(?!rowid)|COUNT)') { continue; }
        if ($logArray[$i] -cmatch '^INSERT') { continue; }
        if ($logArray[$i] -cmatch '^UPDATE') { $logArrayReturn += $logArray[$i] -replace '^UPDATE.+SET (\[\w+\]).+',"`$1 $($logArray[($i+1)]-replace '^\d+ =>','=')"; continue; }
        if ($logArray[$i] -cmatch '^DELETE') { continue; }
        if ($logArray[$i] -cmatch '^insert or replace') {  continue; }
        if ($logArray[$i] -cmatch '^select \[value\]') { continue; }

        #Every line that does not match any string will be passed as the semi-original line.
        $logArrayReturn += $logArray[$i]
        #NOTE: some lines where already passed when being replaced.
    }
    return $logArrayReturn
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
                      ForEach-Object { $_ -replace '^.{31}((\w+ )+#\d+: )?','' } | 
                      Where-Object { $_ -ne '' }


#Save content to file
# logContent | Out-File -FilePath "$logFile.bak"

#Uncomment this line to count the number of matches produced.
# Debug-NumberOfMatches -logArray $logContent

#Here many of the lines will be removed or change to make the log file more understandable.
$logContent = Format-Log $logContent

#The file is created or overwritten with the new content from the logContent variable.
Set-Content $logFile -Value $logContent

Write-Host "`nOpening formatted log .txt file.`n"
#Opens the file.
Invoke-Item $logFile


#END of the script
