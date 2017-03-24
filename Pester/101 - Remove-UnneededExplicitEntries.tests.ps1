Import-Module "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\RemoveSidHistory.psd1"

Describe "SDDL ACL Conversions" {
    It "Verify no change'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Remove-UnneededExplicitEntries $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;BU)'
    }
    It "Verify no change SID'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;S-1-5-32-544)','All')
        (Remove-UnneededExplicitEntries $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;BA)'
    }
    It "Verify removal of single SDDL Name'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)(A;OICIID;0x1200a9;;;BU)','All')
        (Remove-UnneededExplicitEntries $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICIID;0x1200a9;;;BU)'
    }
    It "Verify removal of single SID'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;S-1-5-32-544)(A;OICIID;0x1200a9;;;S-1-5-32-544)','All')
        (Remove-UnneededExplicitEntries $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICIID;0x1200a9;;;BA)'
    }
    It "Verify non removal of same SDDL Name with different permissions'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;FA;;;BA)(A;OICIID;0x1200a9;;;BA)','All')
        (Remove-UnneededExplicitEntries $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;FA;;;BA)(A;OICIID;0x1200a9;;;BA)'
    }
}
