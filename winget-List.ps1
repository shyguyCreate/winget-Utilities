#----------------------------------------------------------
#
#     Author of the script: shyguyCreate
#                Github.com/shyguyCreate
#
#----------------------------------------------------------


######################## For ARP entries ########################

#List for each ARP path.
$Global:arpLM64Programs = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                            Where-Object SystemComponent -ne 1 |
                            Where-Object DisplayName -ne $null |
                            Select-Object -ExpandProperty PSChildName)
$Global:arpLM86Programs = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                            Where-Object SystemComponent -ne 1 |
                            Where-Object DisplayName -ne $null |
                            Select-Object -ExpandProperty PSChildName)
$Global:arpCU64Programs = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                            Where-Object SystemComponent -ne 1 |
                            Where-Object DisplayName -ne $null |
                            Select-Object -ExpandProperty PSChildName)

#Add all the ARP with the new property to a single variable for later.
$Global:arpALLPrograms = $Global:arpLM64Programs + $Global:arpLM86Programs + $Global:arpCU64Programs
$Global:arpALLPrograms = $Global:arpALLPrograms | Sort-Object Name -Unique



######################## For MSIX entries ########################

$Global:msixPrograms = (Get-AppxPackage -PackageTypeFilter Main |
                        Where-Object -Property SignatureKind -ne 'System' |
                        Select-Object -ExpandProperty PackageFamilyName |
                        Sort-Object -Unique)



######################## For Winget List Command ########################

#List for all programs to be sorted in ASCII.
$Global:allPrograms = [System.Collections.ArrayList]::new()

#For some inexplicable reason only when you add one by one the items it can sort correctly in ASCII.
foreach($prog in (($Global:arpALLPrograms | Where-Object Type -eq Program).Name + $Global:msixPrograms))
{
    $Global:allPrograms.Add($prog) > $null
}
#List is sorted in ASCII.
$Global:allPrograms.Sort([System.StringComparer]::Ordinal)



######################## Send Results to Console ########################


Write-Output "`nARP entries for Machine | X64`n"
Write-Output $Global:arpLM64Programs
Write-Output "`nARP entries for Machine | X86`n"
Write-Output $Global:arpLM86Programs
Write-Output "`nARP entries for User | X64`n"
Write-Output $Global:arpCU64Programs
Write-Output "`nARP (MSIX) entries for User | X64`n"
Write-Output $Global:msixPrograms

#List of global variables
Write-Host "`n`n============List of available script variables============`n"
#Gets the variables and prints them with a dollar sign ($) char in the beginning.
Get-Variable -Name all*,arp*,msix* -Exclude *Path -Scope Global | ForEach-Object {Write-Host "`$$($_.Name)"}


#END of the script
