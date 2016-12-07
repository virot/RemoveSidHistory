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
    $SendAlongParam = @{} + $PSBoundParameters
    $SendAlongParam.Remove('Recurse')|Out-Null
    $SendAlongParam.Remove('Path')|Out-Null
    $currentacl = Get-ACL -Literalpath $Path
$currentacl.sddl
#why does Convert-ACL change the $currentacl variable
    $newacl = Convert-ACL -ACL $currentAcl @SendAlongParam
$currentacl.sddl
    $currentacl = Get-ACL -Literalpath $Path
$newacl.sddl

    if ($currentacl.sddl -ne $newacl.sddl -and $pscmdlet.ShouldProcess("$path", "Set New ACL"))
    {
      Write-Host -NoNewline "Setting ACL on $path"
      Set-ACL -LiteralPath $Path  -AclObject $newacl
      Write-Host ' [DONE]'
    }
#Recursive parts
    if ($PSBoundParameters.ContainsKey('Recurse'))
    {
      $SendAlongParam = @{} + $PSBoundParameters
      $SendAlongParam.Remove('Path')|Out-Null
      Get-ChildItem -Directory $Path -PipelineVariable ChildDirs | %  {& $($MyInvocation.MyCommand.Name) -Path $ChildDirs.FullName @SendAlongParam}
    }
  }
}
