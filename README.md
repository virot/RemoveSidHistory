# RemoveSidHistory
Powershell module to assist with removing sidHistories and other SID convertions

# Installation
1. Download module
2. Unblock-File
3. Unpack file
4. Put the files in a folder that is in PSModulePath environment variable:
⋅⋅* Documents\WindowsPowerShell\Modules  (Per User)
⋅⋅* C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules  (Per Computer)

# Examples
## Basic setuo
Load all sidhistories from the AD
```powershell
Add-TranslationTableFromAD
```
Add extra SID that we might want translated even though they dont exist as sidhistory objects
```powershell
Add-TranslationTableWellKnownSids -SourceBaseSID 'S-1-5-21-3-2-1' -DestinationBaseSID 'S-1-5-21-1-2-3'
```
## Basic usage
Convert the rights, owner and ownergroup using
```powershell
Convert-SHRFileSystem -Path C:\temp\example -Verbose -Recurse
```
## Basic saving time
Instead of building the Translation table each time, export and import it if there are no changes made.
```powershell
Export-TranslationTable -Path C:\Temp\export.xml
Import-TranslationTable C:\Temp\export.xml
```