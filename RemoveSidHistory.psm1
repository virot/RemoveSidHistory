$script:TranslationTable = @{}
$script:RemoveSidHistorySIDRegEx = '^(S-1-5-21-[\d]+-[\d]+-[\d]+-[\d]+|S-1-[\d]+-[\d]+-[\d]+|S-1-[\d]+-[\d]+|S-1-[\d]+|AN|AO|AU|BA|BG|BO|BU|CA|CD|CG|CO|DA|DC|DD|DG|DU|EA|ED|HI|IU|LA|LG|LS|LW|ME|MU|NO|NS|NU|PA|PO|PS|PU|RC|RD|RE|RO|RS|RU|SA|SI|SO|SU|SY|WD)$'
$DebugMessage = {Param([string]$Message);"$(get-date -Format 's') [$((Get-Variable -Scope 1 MyInvocation -ValueOnly).MyCommand.Name)]: $Message"}

. "$PSScriptRoot\Includes\Add-TranslationTableEntry.ps1"
. "$PSScriptRoot\Includes\Add-TranslationTableFromAD.ps1"
. "$PSScriptRoot\Includes\Add-TranslationTableWellKnownSids.ps1"
. "$PSScriptRoot\Includes\Clear-TranslationTable.ps1"
. "$PSScriptRoot\Includes\Get-TranslationTable.ps1"
. "$PSScriptRoot\Includes\Convert-FileSystem.ps1"
. "$PSScriptRoot\Includes\Export-TranslationTable.ps1"
. "$PSScriptRoot\Includes\Import-TranslationTable.ps1"
. "$PSScriptRoot\Includes\Remove-TranslationTableEntry.ps1"
. "$PSScriptRoot\Includes\Remove-UnneededExplicitEntries.ps1"
. "$PSScriptRoot\Includes\Convert-ACL.ps1"
