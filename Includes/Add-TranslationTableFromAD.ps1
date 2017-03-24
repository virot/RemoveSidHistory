Function Add-TranslationTableFromAD
{
  $domain = New-Object System.DirectoryServices.DirectoryEntry
  $searcher = [adsisearcher]$domain
  $searcher.PageSize = 1000000
  $searcher.Filter = '(sidhistory=*)'
  $searcher.FindAll() | % {
    ForEach ($SidHistory in ($_.Properties['sidhistory']))
    {
      Add-TranslationTableEntry -SourceSID (new-object System.Security.Principal.SecurityIdentifier $SidHistory,0).toString() -DestionationSID (new-object System.Security.Principal.SecurityIdentifier $SidHistory,0).toString()
    }
  }
}