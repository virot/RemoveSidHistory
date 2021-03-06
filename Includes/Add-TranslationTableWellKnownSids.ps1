Function Add-TranslationTableWellKnownSids
{
[CmdletBinding(SupportsShouldProcess=$false)]
  param(
  [string]
  [Parameter(ParameterSetName=íSourceSID to DestinationSIDí)]
  [Parameter(ParameterSetName=íSourceSID to DestinationDNí)]
  $SourceBaseSID,
  [string]
  [Parameter(ParameterSetName=íSourceSID to DestinationSID')]
  [Parameter(ParameterSetName=íSourceDN to DestinationSIDí)]
  $DestinationBaseSID,
  [string]
  [Parameter(ParameterSetName=íSourceDN to DestinationSIDí)]
  [Parameter(ParameterSetName=íSourceDN to DestinationDNí)]
  $SourceDN,
  [string]
  [Parameter(ParameterSetName=íSourceSID to DestinationDNí)]
  [Parameter(ParameterSetName=íSourceDN to DestinationDNí)]
  $DestinationDN
  )
  Begin
  {
    $WellKnownRIDs = '500','501','502','512','513','514','515','516','517','520','553'
    $WellKnownRIDsROOTONLY = '518','520'
    Write-Verbose "Working with $($PsCmdlet.ParameterSetName)"
    switch ($PsCmdlet.ParameterSetName) 
    { 
      {'SourceDN to DestinationSID','SourceDN to DestinationDN' -contains $_} {
        Try
        {
          $SourceBaseSID = (new-object System.Security.Principal.SecurityIdentifier ((New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($SourceDN)")).objectSid[0],0)).toString()
          Write-Verbose "Resolved $($SourceDN) to $($SourceBaseSID)"
        }
        Catch [System.DirectoryServices.DirectoryServicesCOMException]
        {Throw 'Unsable to resolve source distinguishedName'}
        Catch
        {Throw 'Something else'}
      } 
      {'SourceSID to DestinationDN','SourceDN to DestinationDN' -contains $_} {
        Try
        {
          $DestinationBaseSID = (new-object System.Security.Principal.SecurityIdentifier ((New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($DestinationDN)")).objectSid[0],0)).toString()
          Write-Verbose "Resolved $($DestinationDN) to $($DestinationBaseSID)"
        }
        Catch [System.DirectoryServices.DirectoryServicesCOMException]
        {Throw 'Unsable to resolve source distinguishedName'}
        Catch
        {Throw 'Something else'}
      }
    }#End switch $PsCmdlet.ParameterSetName
  }#End Begin
  Process
  {
    ForEach ($rid in $WellKnownRIDs)
    {
      Add-TranslationTableEntry -SourceSID "$($SourceBaseSID)-$($rid)" -DestinationSID "$($DestinationBaseSID)-$($rid)"
    }
  }
}