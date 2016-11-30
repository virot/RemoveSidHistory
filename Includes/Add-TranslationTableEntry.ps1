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
    $TranslationTable[$SourceSID] = $DestinationSID
  }
}