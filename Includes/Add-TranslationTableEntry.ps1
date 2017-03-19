Function Add-TranslationTableEntry
{
  param(
  [string]
  [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
  $SourceSID,
  [string]
  [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
  $DestinationSID
  )
  Process
  {
    if ($TranslationTable.ContainsKey($DestinationSID))
    {
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