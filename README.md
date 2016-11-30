# RemoveSidHistory
Powershell module to assist with removing sidHistories and other SID convertions

# Installation
1. Download module
2. Unblock-File
3. Unpack file
4. Put the files in a folder that is in PSModulePath environment variable:
..*Documents\WindowsPowerShell\Modules  (Per User)
..*C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules  (Per Computer)

# Examples

Load all sidhistories from the AD
`Add-TranslationTableFromAD`
Add extra SID that we might want translated even though they dont exist as sidhistory objects
`Add-TranslationTableWellKnownSids -SourceBaseSID 'S-1-5-21-3-2-1' -DestinationBaseSID 'S-1-5-21-1-2-3'`
Convert the rights, owner and ownergroup using
`Convert-SHRFileSystem -Path C:\temp\example -Verbose -Recurse`