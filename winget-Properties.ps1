#----------------------------------------------------------
#
#     Author of the script: shyguyCreate
#                Github.com/shyguyCreate
#
#----------------------------------------------------------


#Path to a temp file
$tmpFilePath = New-TemporaryFile

#Sends [winget list] to a file with special enconding to not mess with special characters
Out-File -FilePath $tmpFilePath -InputObject (winget list -s winget) -Encoding Oem -Force

#Gets the content of the file in UTF8 to not mess with special characters
$tmpFileContent = Get-Content -Path $tmpFilePath -Encoding UTF8

#Delete temp file
Remove-Item $tmpFilePath


$hyphenIndex = 0
#Search for the line that is all hyphens
while ($tmpFileContent[$hyphenIndex] -notmatch ('^-+$'))
{
    $hyphenIndex++
}

#Go back one index to get the properties line
$propertiesIndex = $hyphenIndex - 1
#Go one index forward to skip the hyphens line
$skipHyphenIndex = $hyphenIndex + 1
#Get number of lines in the file
$lastIndex = $tmpFileContent.Length - 1

#Saves the Properties line and everything below the hyphen line
$newContent = $tmpFileContent[,$propertiesIndex+$skipHyphenIndex..$lastIndex]


#Replace extra spaces with one space and split them by the space between them
$propetyNames = ($newContent[0] -replace '\s+', ' ').Split(' ')


$indexes = [System.Collections.ArrayList]::new()
#Look for the indexes of the Properties names
for ($i = 1; $i -lt $propetyNames.Count; $i++)
{
    $indexes.Add($newContent[0].IndexOf($propetyNames[$i]) - 1) > $null
}


[array] $Global:wingetList = @()

#Changes the character before the Property name to a comma and removes the spaces before the comma
foreach ($line in $newContent)
{
    foreach($index in $indexes)
    {
        $Global:wingetList += $line.Remove($index,1).Insert($index,',') -replace '\s+,',','
    }
}

#Convert the Csv to Properties, and name each Property by the first line found in the list
$Global:wingetList = $Global:wingetList | ConvertFrom-Csv


#Prints the winget list but now with properties
$Global:wingetList
#Prints help message
Write-Host "`n`tCommand: `$wingetList`n"


#END of the script
