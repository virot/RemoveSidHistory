$myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$wp = New-Object Security.Principal.WindowsPrincipal($MyIdentity)

Describe "Convert-Share" {
    It "Tests requires 'Administrative Privileges'" {
        ($wp.IsInRole([Security.Principal.WindowsbuiltInRole]::Administrator)) | Should Be $True
    }
    If ($wp.IsInRole([Security.Principal.WindowsbuiltInRole]::Administrator))
    {
        It "outputs 'Only as Admin'" {
            Write-Output 'Hello' | Should Be 'Hello'
        }
    }
}
