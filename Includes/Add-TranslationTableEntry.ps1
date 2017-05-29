Function Add-TranslationTableEntry
{
  param(
  [Parameter(Mandatory=$true)]
  [string]
  [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
  $SourceSID,
  [Parameter(Mandatory=$true)]
  [string]
  [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
  $DestinationSID
  )
  Process
  {
    Write-Verbose "Adding Translation entry $SourceSID=>$DestinationSID"
    if ($TranslationTable.ContainsKey($DestinationSID))
    {
      Write-Verbose "Found match for DestinationSID in `$TranslationTable"
      if ($SourceSID -eq $TranslationTable[$DestinationSID])
      {
        throw ("Translating `"$SourceSID`" to `"$DestinationSID`" would create a loop.")
      }
      else
      {
        $TranslationTable[$SourceSID] = $TranslationTable[$DestinationSID]
      }
    }
    else
    {
      if ($TranslationTable.ContainsValue($SourceSID))
      {
        Write-Verbose "Found match for SourceSID in `$TranslationTable"
        ForEach ($Key in ($TranslationTable.Keys).clone())
        {
          if ($TranslationTable[$Key] -eq $SourceSID)
          {
            $TranslationTable[$Key] = $DestinationSID
          }
        }
      }
      $TranslationTable[$SourceSID] = $DestinationSID
    }
  }
}