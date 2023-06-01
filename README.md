# Winget Utilities

Scripts based on some `winget` functionalities or lack of them.

------------------------

### winget-List

This script will look through the registry, grab installed programs, and stored them in variables. The script should mimic the way `winget list` find installed programs and should output a similar number of programs found in the system.

------------------------

### winget-Logs

This script will look through the last created log, and delete all the unnecessary lines that repeat too many times or rewrite details in a way that is easier to understand what `winget` is doing.

------------------------

### winget-Properties

This script transforms the output of `winget list`, into powershell object properties that makes its output more reusable for dealing with its information. The script transform every column: `Name`, `Id`, `Available`, and `Version`; into properties inside a variable called **$wingetList**.

------------------------
