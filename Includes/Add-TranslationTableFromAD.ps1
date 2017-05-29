Function Add-TranslationTableFromAD
{
  param
  (
  [string]
  $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Name
  )
  Process
  {
    $DomainDN = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain([System.DirectoryServices.ActiveDirectory.DirectoryContext]::new([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain, $Domain)).GetDirectoryEntry().DistinguishedName
    $searcher = [System.DirectoryServices.DirectorySearcher]::New([ADSI]"LDAP://$domainDN")
    $searcher.PageSize = 1000000
    $searcher.Filter = '(sidhistory=*)'
    ForEach ($user in $searcher.FindAll()) {
      ForEach ($SidHistory in ($user.Properties['sidhistory']))
      {
        Add-TranslationTableEntry -SourceSID (new-object System.Security.Principal.SecurityIdentifier $SidHistory,0).toString() -DestinationSID (new-object System.Security.Principal.SecurityIdentifier $user.Properties['objectsid'][0],0).toString()
      }
    }
  }
}