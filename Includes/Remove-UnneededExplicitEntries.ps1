Function Remove-UnneededExplicitEntries
{
[CmdletBinding(SupportsShouldProcess=$true)]
  param
  (
    [System.Security.AccessControl.FileSystemSecurity]
    [Parameter(Mandatory=$true)]
    $ACL
  )
  Process
  {
    $newacl = New-Object System.Security.AccessControl.Directorysecurity
    $newacl.SetSecurityDescriptorSddlForm($acl.Sddl)
#Create array of text representation as Powershell cant handle all types of FilesystemRights
    $ImplicitRules = ForEach ($ace in ($acl.GetAccessRules($false, $true, [System.Security.Principal.SecurityIdentifier])))
    {
      "$($ace.IdentityReference)$($ace.FilesystemRights)$($ace.InheritanceFlags)$($ace.PropagationFlags)$($ace.AccessControlType)"
    }
#Walk through all explicit rules and try to find unnneded ones.
    ForEach ($ace in ($acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier])))
    {
      if ($ImplicitRules -contains ("$($ace.IdentityReference)$($ace.FilesystemRights)$($ace.InheritanceFlags)$($ace.PropagationFlags)$($ace.AccessControlType)"))
      {
        Write-Verbose "Removing unneeded right for $($ace.IdentityReference)"
        $newacl.RemoveAccessRuleSpecific($ace)
      }
    }
    return $newacl
  }
}
