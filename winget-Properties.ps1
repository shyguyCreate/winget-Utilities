#----------------------------------------------------------
#
#     Author of the script: shyguyCreate
#                Github.com/shyguyCreate
#
#----------------------------------------------------------


#Path to a temp file.
$tmpFilePath = New-TemporaryFile

#Sends [winget list] to a file with special enconding, so that it doesn't mess with special characters.
Out-File -FilePath $tmpFilePath -InputObject (winget list -s winget) -Encoding Oem -Force

#Gets the content of the file in UTF8 so that it doesn't changes accents and other special characters
#And skips the first two lines which are some sort of loading process.
$tmpFileContent = Get-Content -Path $tmpFilePath -Encoding UTF8

#Delete temp file
Remove-Item $tmpFilePath


$hyphenIndex = 0
#Search for the line that is all hyphens
while ($tmpFileContent[$hyphenIndex] -notmatch ("^-+$"))
{
    $hyphenIndex++
}

#Go back one index to get the properties line.
$propertiesIndex = $hyphenIndex - 1
#Go one index forward to skip the hyphens line.
$skipHyphenIndex = $hyphenIndex + 1
#Get number of lines in the file.
$lastIndex = $tmpFileContent.Length - 1

#Saves the Properties line to later add everything below except for the hyphen line.
[array] $newContent = $tmpFileContent[$propertiesIndex]
$newContent += $tmpFileContent[$skipHyphenIndex..$lastIndex]


#Replace extra spaces with one space and split them by the space between them.
$propetyNames = ($newContent[0] -replace '\s+', ' ').Split(' ')


$indexes = [System.Collections.ArrayList]::new()
#Look for the indexes of the Properties names.
for ($i = 1; $i -lt $propetyNames.Count; $i++)
{
    $indexes.Add($newContent[0].IndexOf($propetyNames[$i]) - 1) > $null
}



[array] $Global:wingetList = @()
[array] $Global:wingetCsv = @()

foreach ($line in $newContent)
{
    #Changes the character before the Property name to a comma, except the first Property.
    #And repeats the process foreach line.
    foreach($index in $indexes)
    {
        $line = $line.Remove($index,1).Insert($index,",")
    }

    #Removes the spaces between the program and the comma.
    $line = $line -replace '\s+,', ','

    #It adds all the modifications to a variable to be later use to fill a .txt file.
    $Global:wingetCsv += $line
}

#Convert the Csv to Properties, and name each Property by the first line found in the list.
$Global:wingetList = $Global:wingetCsv | ConvertFrom-Csv


#Prints the winget list but now with properties.
$Global:wingetList
#Prints help message
Write-Output "`n`tCommand: `$wingetList`tNOTE: Also available `$wingetCsv`n"


#END of the script
