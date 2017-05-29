Import-Module "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\RemoveSidHistory.psd1"
Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'AU'


Describe "SDDL ACL Conversions" {
    It "outputs 'Change BU->DU'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)','All')
        (Convert-ACL $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;DU)'
    }
    It "outputs 'Change S-1-5-32-544->BA (Due to way of scripts)'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;S-1-5-32-544)','All')
        (Convert-ACL $acl).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;BA)'
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
    It "'Keep changed ACEs if SaveConvertedACEs:$True'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)(A;OICI;0x1200a9;;;BA)','All')
        (Convert-ACL $acl -SaveConvertedACEs:$True).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;BA)(A;OICI;0x1200a9;;;BU)(A;OICI;0x1200a9;;;DU)'
    }
    It "'Remove changed ACEs if SaveConvertedACEs:$False'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)(A;OICI;0x1200a9;;;BA)','All')
        (Convert-ACL $acl -SaveConvertedACEs:$False).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;BA)(A;OICI;0x1200a9;;;DU)'
    }
    It "'Remove double ACEs'" {
        $acl = New-Object System.Security.AccessControl.Directorysecurity
        $acl.SetSecurityDescriptorSddlForm('O:BAG:BAD:PAI(A;OICI;0x1200a9;;;BU)(A;OICI;0x1200a9;;;DU)','All')
        (Convert-ACL $acl -SaveConvertedACEs:$False).GetSecurityDescriptorSddlForm('Access') | Should Be 'D:PAI(A;OICI;0x1200a9;;;DU)'
    }
}
