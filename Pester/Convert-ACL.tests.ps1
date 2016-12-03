. "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\Includes\Convert-ACL.ps1"
$TranslationTable = @{}
$TranslationTable.Add('BU','DU')
$TranslationTable.Add('S-1-0-0','DA')
$TranslationTable.Add('S-1-5-21-1-2-3-4','AU')


Describe "SDDL ACL Conversions" {
    It "outputs 'Change BU->DU'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;DU)'
    }
    It "outputs 'ForceOwner to Everyone'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl -ForceOwner 'WD').GetSecurityDescriptorSddlForm('Owner') | Should Be 'O:WD'
    }
    It "'ChangeOwner enabled'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BUG:BAD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl -ChangeOwner).GetSecurityDescriptorSddlForm('Owner') | Should Be 'O:DU'
    }
    It "'ChangeOwner NOT enabled'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BUG:BAD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl).GetSecurityDescriptorSddlForm('Owner') | Should Be 'O:BU'
    }
    It "outputs 'ForceGroup to Everyone'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BUD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl -ForceGroup 'WD').GetSecurityDescriptorSddlForm('Group') | Should Be 'G:WD'
    }
    It "'ChangeGroup enabled'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BUG:BUD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl -ChangeGroup).GetSecurityDescriptorSddlForm('Group') | Should Be 'G:DU'
    }
    It "'ChangeGroup NOT enabled'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BUG:BUD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl).GetSecurityDescriptorSddlForm('Group') | Should Be 'G:BU'
    }
}
