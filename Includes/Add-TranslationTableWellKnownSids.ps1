Function Add-TranslationTableWellKnownSids
{
  param(
  [string]
  $SourceBaseSID,
  [string]
  $DestinationBaseSID
  )
  Process
  {
    $WellKnownRIDs = '500','501','502','512','513','514','515','516','517','520','553'
    $WellKnownRIDsROOTONLY = '518','520'
    ForEach ($rid in $WellKnownRIDs)
    {
      $TranslationTable["$($SourceBaseSID)-$($rid)"] = "$($DestinationBaseSID)-$($rid)"
    }
  }
}