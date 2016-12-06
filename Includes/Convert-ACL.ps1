Function Convert-ACL
{
[CmdletBinding(SupportsShouldProcess=$true)]
  param
  (
    [System.Security.AccessControl.FileSystemSecurity]
    [Parameter(Mandatory=$true)]
    $ACL,
    [switch]
    $ChangeOwner,
    [string]
    [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
    $ForceOwner,
    [switch]
    $ChangeGroup,
    [string]
    [ValidateScript({if ($_ -inotmatch $RemoveSidHistorySIDRegEx){Throw 'Incorrect SID format or SDDL SID Name'}else{$true}})]
    $ForceGroup
  )
  Begin
  {
#Fix so SACL also work
    $sddlFormat = 'O:([^:]*)G:([^:]*)D:([A-Z]*)(\(.*\))'
    $aceFormat = '\(?(A|D);([^;]*);([^;]*);([^;]*);([^;]*);([0-9A-Z-]*)\)?'
  }
  Process
  {
#Update Owner
    if ($PSBoundParameters.ContainsKey('ChangeOwner') -or $PSBoundParameters.ContainsKey('ForceOwner'))
    {
      $sddlOwner = $acl.GetSecurityDescriptorSddlForm('Owner')
      if ($PSBoundParameters.ContainsKey('ForceOwner')) 
      {
        Write-Verbose "Changing owner from `"$sddlOwner`" to `"O:$ForceOwner`""
        $sddlOwner = "O:$ForceOwner"
      }
      elseif ($TranslationTable.ContainsKey($sddlOwner -replace '^O:'))
      {  
        Write-Verbose "Changing owner from `"$sddlOwner`" to `"O:$($TranslationTable[$sddlOwner -replace '^O:'])`""
        $sddlOwner = "O:$($TranslationTable[$sddlOwner -replace '^O:'])"
      }
      $acl.SetSecurityDescriptorSddlForm($sddlOwner,'Owner')
    }
#Update Group
    if ($PSBoundParameters.ContainsKey('ChangeGroup') -or $PSBoundParameters.ContainsKey('ForceGroup'))
    {
      $sddlGroup = $acl.GetSecurityDescriptorSddlForm('Group')
      if ($PSBoundParameters.ContainsKey('ForceGroup')) 
      {
        Write-Verbose "Changing group from `"$sddlgroup`" to `"G:$ForceGroup`""
        $sddlGroup = "G:$($ForceGroup)"
      }
      elseif ($TranslationTable.ContainsKey($sddlGroup -replace '^G:'))
      {  
        Write-Verbose "Changing group from `"$sddlGroup`" to `"O:$($TranslationTable[$sddlGroup -replace '^G:'])`""
        $sddlGroup = "G:$($TranslationTable[$sddlGroup -replace '^G:'])"
      }
      $acl.SetSecurityDescriptorSddlForm($sddlGroup,'Group')
    }
#Update Access
    $newACEs = ForEach ($ace in ($acl.GetSecurityDescriptorSddlForm('Access') -split '(\([^)]*\))' -ne ''))
    {
      if ($ace -match $aceFormat)
      {
        if ($PSBoundParameters.ContainsKey('SaveOld'))
        {
          $ace
        }
        if ($TranslationTable.keys -contains $Matches[6] -and $Matches[2] -notlike '*ID*')
        {
          $newace = "($($ace -replace '\((.*;)[A-Z0-9-]*\)','$1')$($TranslationTable[$Matches[6]]))"
          Write-Verbose "From:`t`"$ace`""
          Write-Verbose "To:`t`"$newace`""
          $newace
        }
        elseif ($PSBoundParameters.ContainsKey('SaveOld') -eq $false)
        {
          $ace
        }
      }
      else
      {
        $ace
      }
    }
    $acl.SetSecurityDescriptorSddlForm(($newACEs -join ''),'Access')
#Update Audit
    Return $ACL
  }
}
