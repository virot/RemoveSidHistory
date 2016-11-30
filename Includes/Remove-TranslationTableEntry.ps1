$script:RemoveSidHistorySIDRegEx = '^(S-1-5-21-[\d]+-[\d]+-[\d]+-[\d]+|S-1-[\d]+-[\d]+-[\d]+|S-1-[\d]+-[\d]+|S-1-[\d]+|AN|AO|AU|BA|BG|BO|BU|CA|CD|CG|CO|DA|DC|DD|DG|DU|EA|ED|HI|IU|LA|LG|LS|LW|ME|MU|NO|NS|NU|PA|PO|PS|PU|RC|RD|RE|RO|RS|RU|SA|SI|SO|SU|SY|WD)$'
Function Remove-TranslationTableEntry
{
  param(
  [string]
  [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
  $Source
  )
  Process
  {
    $TranslationTable.remove($Source)
  }
}