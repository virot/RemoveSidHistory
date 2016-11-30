Function Add-TranslationTableFromAD
{
  $domain = New-Object System.DirectoryServices.DirectoryEntry
  $searcher = [adsisearcher]$domain
  $searcher.PageSize = 1000000
  $searcher.Filter = '(sidhistory=*)'
  $searcher.FindAll() | % {
    ForEach ($SidHistory in ($_.Properties['sidhistory']))
    {
#      $TranslationTable[(new-object System.Security.Principal.SecurityIdentifier ($_.Properties['objectsid'][0],0)).toString()] = (new-object System.Security.Principal.SecurityIdentifier $SidHistory,0).toString()
      $TranslationTable[(new-object System.Security.Principal.SecurityIdentifier $SidHistory,0).toString()] = (new-object System.Security.Principal.SecurityIdentifier ($_.Properties['objectsid'][0],0)).toString()
    }
  }
}