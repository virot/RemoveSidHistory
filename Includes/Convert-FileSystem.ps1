Function Convert-FileSystem
{
[CmdletBinding(SupportsShouldProcess=$true)]
  param
  (
    [string]
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Literalpath $_})]
    [ValidateLength(1,260)]
    $Path,
    [switch]
    $Recurse,
    [switch]
    $SaveOld
  )
  Begin
  {
#Fix so SACL also work
    $sddlFormat = 'O:([^:]*)G:([^:]*)D:([A-Z]*)(\(.*\))'
    $aceFormat = '\(?(A|D);([^;]*);([^;]*);([^;]*);([^;]*);([0-9A-Z-]*)\)?'
  }
  Process
  {
    $ChangedACL = $false
    $acl = Get-ACL -Literalpath $Path
    $currentSDDL = $acl.Sddl
    $sddlOwner = $currentSDDL -replace $sddlFormat, '$1'
    if ($SIDhistoryTranslate.keys -contains $sddlOwner)
    {
      $ChangedACL = $true
      Write-Verbose "Changing owner on $Path"
      $sddlOwner = $SIDhistoryTranslate[$sddlOwner]
    }
    $sddlGroup =  $currentSDDL -replace $sddlFormat, '$2'
    if ($SIDhistoryTranslate.keys -contains $sddlGroup)
    {
      $ChangedACL = $true
      Write-Verbose "Changing group on $Path"
      $sddlGroup = $SIDhistoryTranslate[$sddlGroup]
    }
    $sddlACLProtected =  $currentSDDL -replace $sddlFormat, '$3'
    $newSDDL= "O:$($sddlOwner)G:$($sddlGroup)D:$($sddlACLProtected)"
    $newACEs = ForEach ($ace in ($currentSDDL -replace $sddlFormat, '$4' -split '\)\('))
    {
      if ($SaveOld)
      {
        ($ace -replace "^\(?([^)]*)\)?$",'($1)')
      }
      if ($ace -match $aceFormat)
      {
        if ($global:SIDhistoryTranslate.keys -contains $Matches[6] -and $Matches[2] -notlike '*ID*')
        {
          $ChangedACL = $true
          Write-Verbose "Modifying ACE entry on $Path"
          Write-Verbose "From:`t($($ace -replace '\(?(.*?)\)?','$1'))"
          Write-Verbose "To:`t($($ace -replace '\(?(.*;)[A-Z0-9-]*\)?','$1')$($global:SIDhistoryTranslate[$Matches[6]]))"
          "($($ace -replace '\(?(.*;)[A-Z0-9-]*\)?','$1')$($global:SIDhistoryTranslate[$Matches[6]]))"
        }
        elseif ($SaveOld -eq $false)
        {
          ($ace -replace "^\(?([^)]*)\)?$",'($1)')
        }
      }
    }
    $newSDDL += $newACEs -join ''
    if ($newSDDL -ne $currentSDDL -and $pscmdlet.ShouldProcess("$path", "Set New ACL") -and $ChangedACL -eq $true)
    {
      Write-Host -NoNewline "Setting ACL on $path"
      $CorrectACL = New-Object System.Security.AccessControl.Directorysecurity 
      $CorrectACL.SetSecurityDescriptorSddlForm($newSDDL)
      Set-ACL -LiteralPath $Path  -AclObject $CorrectACL
      Write-Host '[DONE]'
    }
#Recursive parts
    Get-ChildItem -Directory $Path -PipelineVariable ChildDirs | % {Convert-SHRFileSystem -Path $ChildDirs.FullName -Recurse:$Recurse -SaveOld:$SaveOld}
  }
}
