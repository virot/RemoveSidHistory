       
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
    $ForceGroup,
    [Bool]
    $SaveConvertedACEs = $False
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
    $newacl = Convert-ACL -ACL $currentAcl @SendAlongParam
    if (($currentacl.GetSecurityDescriptorSddlForm('Access') -replace '^[^(]*' -replace "\([^\(]*ID[^\)]*\)",'') -ne ($newacl.GetSecurityDescriptorSddlForm('Access') -replace '^[^(]*' -replace "\([^\(]*ID[^\)]*\)",'') -and $pscmdlet.ShouldProcess("$path", "Set New ACL"))
    {
      Write-Verbose (&$DebugMessage "Starting to set ACL on $path")
      Set-ACL -LiteralPath $Path  -AclObject $newacl
      Write-Verbose (&$DebugMessage "Completed to set ACL on $path")
    }
    else
    {
      Write-Verbose (&$DebugMessage "ACL correct on $path")
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
