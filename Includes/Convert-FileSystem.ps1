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
    $SaveOld,
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
  }
  Process
  {
    $aclparam = @{}
    if ($PSBoundParameters.ContainsKey('SwitchOwner')) {$aclparam.add('ChangeOwner',$ChangeOwner)}
    if ($PSBoundParameters.ContainsKey('ForceOwner')) {$aclparam.add('ForceOwner',$ForceOwner)}
    if ($PSBoundParameters.ContainsKey('SwitchGroup')) {$aclparam.add('ChangeGroup',$ChangeGroup)}
    if ($PSBoundParameters.ContainsKey('ForceGroup')) {$aclparam.add('ForceGroup',$ForceGroup)}
    $currentacl = Get-ACL -Literalpath $Path
$currentacl.sddl
#why does Convert-ACL change the $currentacl variable
    $newacl = Convert-ACL -ACL $currentAcl @aclparam
$currentacl.sddl
    $currentacl = Get-ACL -Literalpath $Path
$newacl.sddl

    if ($currentacl.sddl -ne $newacl.sddl -and $pscmdlet.ShouldProcess("$path", "Set New ACL"))
    {
      Write-Host -NoNewline "Setting ACL on $path"
      $CorrectACL = New-Object System.Security.AccessControl.Directorysecurity 
      $CorrectACL.SetSecurityDescriptorSddlForm($newSDDL)
      Set-ACL -LiteralPath $Path  -AclObject $CorrectACL
      Write-Host '[DONE]'
    }
#Recursive parts
    Get-ChildItem -Directory $Path -PipelineVariable ChildDirs | %  {& $($MyInvocation.MyCommand.Name) -Path $ChildDirs.FullName -Recurse:$Recurse -SaveOld:$SaveOld}
  }
}
