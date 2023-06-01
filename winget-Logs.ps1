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
    $Stepping_statement = 0;        $_arrow_ = 0
    $Statement_has_completed = 0;   $SELECT_WHERE = 0
    $Statement_has_data = 0;        $INSERT = 0
    $_savepoint = 0;                $SELECT_WHERE_ = 0
    $SAVEPOINT = 0;                 $SELECT_COUNT = 0
    $ROLLBACK = 0;                  $UPDATE = 0
    $RELEASE = 0;                   $DELETE = 0
    $_TABLE = 0;                    $ORDER_BY = 0
    $Reset_statement = 0;           $select_value = 0
    $_INDEX = 0;
    $Setting_action = 0;

    #Here the matches will be count.
    for ($i = 0; $i -lt $logArray.Length; $i++)
    {
        #First part
        if ($logArray[$i] -match '^Stepping statement #\d+$') {  $Stepping_statement++;  continue; }
        if ($logArray[$i] -match '^Statement #\d+ has completed$') {  $Statement_has_completed++;  continue; }
        if ($logArray[$i] -match '^Statement #\d+ has data$') {  $Statement_has_data++;  continue; }
        if ($logArray[$i] -match '^(\w+ )+savepoint:') {  $_savepoint++;  continue; }
        if ($logArray[$i].StartsWith('SAVEPOINT')) {  $SAVEPOINT++;  continue; }
        if ($logArray[$i].StartsWith('ROLLBACK')) {  $ROLLBACK++;  continue; }
        if ($logArray[$i].StartsWith('RELEASE')) {  $RELEASE++;  continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+TABLE') {  $_TABLE++;  continue; }
        if ($logArray[$i] -match '^Reset statement #\d+$') {  $Reset_statement++;  continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+INDEX') {  $_INDEX++;  continue; }
        if ($logArray[$i].StartsWith('Setting action:')) {  $Setting_action++;  continue; }

        #Second part
        if ($logArray[$i] -cmatch '^\d+ =>') {  $_arrow_++; continue; }
        if ($logArray[$i] -cmatch '^SELECT \[.+WHERE (\[\w+\]) ') {  $SELECT_WHERE++; continue; }
        if ($logArray[$i] -match '^INSERT') {  $INSERT++; continue; }
        if ($logArray[$i].StartsWith('SELECT COUNT')) {  $SELECT_COUNT++; continue; }
        if ($logArray[$i] -cmatch '^SELECT \[.+WHERE (\[\w+\])\.') {  $SELECT_WHERE_++; continue; }
        if ($logArray[$i].StartsWith('UPDATE')) {  $UPDATE++; continue; }
        if ($logArray[$i].StartsWith('DELETE')) {  $DELETE++; continue; }
        if ($logArray[$i].EndsWith('ORDER BY [t].[sort]')) {  $ORDER_BY++; continue; }
        if ($logArray[$i].StartsWith('select [value]')) {  $select_value++; continue; }
    }

    Write-Output "
    `r`$Stepping_statement: $Stepping_statement
    `r`$Statement_has_completed: $Statement_has_completed
    `r`$Statement_has_data: $Statement_has_data
    `r`$_savepoint: $_savepoint
    `r`$SAVEPOINT: $SAVEPOINT
    `r`$ROLLBACK: $ROLLBACK
    `r`$RELEASE: $RELEASE
    `r`$_TABLE: $_TABLE
    `r`$Reset_statement: $Reset_statement
    `r`$_INDEX: $_INDEX
    `r`$Setting_action: $Setting_action

    `r`$_arrow_: $_arrow_
    `r`$SELECT_WHERE: $SELECT_WHERE
    `r`$INSERT: $INSERT
    `r`$SELECT_COUNT: $SELECT_COUNT
    `r`$SELECT_WHERE_: $SELECT_WHERE_
    `r`$UPDATE: $UPDATE
    `r`$DELETE: $DELETE
    `r`$ORDER_BY: $ORDER_BY
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
        if ($logArray[$i] -match '^Stepping statement #\d+$') { continue; }
        if ($logArray[$i] -match '^Statement #\d+ has completed$') { continue; }
        if ($logArray[$i] -match '^Statement #\d+ has data$') { continue; }
        if ($logArray[$i] -match '^(\w+ )+savepoint:') { continue; }
        if ($logArray[$i].StartsWith('SAVEPOINT')) { continue; }
        if ($logArray[$i].StartsWith('ROLLBACK')) { continue; }
        if ($logArray[$i].StartsWith('RELEASE')) { continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+TABLE') { continue; }
        if ($logArray[$i] -match '^Reset statement #\d+$') { continue; }
        if ($logArray[$i] -cmatch '^(\w+ )+INDEX') { continue; }
        if ($logArray[$i].StartsWith('Setting action:')) { continue; }

        #Here is the fun part where a lot of data will not get to the final file, some will be joined with another line
        #to generate less lines overall and some will be replaced by shorted version from their original lines.
        #Comment lines at your consideration.
        if ($logArray[$i] -cmatch '^\d+ =>') { continue; }
        if ($logArray[$i] -cmatch '^SELECT \[.+WHERE (\[\w+\]) ') { $logArrayReturn += $logArray[$i] -replace '^SELECT.+WHERE (\[\w+\]).+',"`$1 $($logArray[($i+1)] -replace '^\d+ =>','=')"; continue; }
        if ($logArray[$i] -match '^INSERT') { continue; }
        if ($logArray[$i].StartsWith('SELECT COUNT')) { continue; }
        if ($logArray[$i] -cmatch '^SELECT \[.+WHERE (\[\w+\])\.') { continue; }
        if ($logArray[$i].StartsWith('UPDATE')) { $logArrayReturn += $logArray[$i] -replace '^UPDATE.+SET (\[\w+\]).+',"`$1 $($logArray[($i+1)]-replace '^\d+ =>','=')"; continue; }
        if ($logArray[$i].StartsWith('DELETE')) { continue; }
        if ($logArray[$i].EndsWith('ORDER BY [t].[sort]')) { continue; }
        if ($logArray[$i].StartsWith('select [value]')) { continue; }

        #Every line that does not match any string will be passed as the semi-original line.
        $logArrayReturn += $logArray[$i]
        #NOTE: some lines where already passed when being replaced.
    }
    return $logArrayReturn
}



# ============================================================================================

################################# Start Main Program #########################################


#Get last created winget log.
$logFile = (Get-Item "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir\WinGet*" |
            Sort-Object CreationTime | Select-Object -ExpandProperty FullName -Last 1)


#Get log lines only if it starts with a 4 digit number.
#And remove words followed by a hashtag and numbers if exists.
[array] $logContent = Get-Content $logFile |
                      Where-Object { $_ -match '^\d{4}' } |
                      ForEach-Object { $_ -replace "^.{31}((\w+ )+#\d+: )?",'' } | 
                      Where-Object { $_ -ne '' }


#Save content to file
New-Item -Path "$logFile.bak" -Value $logContent -ItemType File

#Uncomment this line to count the number of matches produced.
# Debug-NumberOfMatches -logArray $logContent

#Here many of the lines will be removed or change to make the log file more understandable.
$logContent = Format-Log $logContent

#The file is created or overwritten with the new content from the logContent variable.
Set-Content $logFile -Value $logContent

Write-Host "`nOpening formatted log .txt file."
#Opens the file.
Invoke-Item $logFile


#END of the script
