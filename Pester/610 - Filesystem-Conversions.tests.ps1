$PesterBaseTestPath = "$([system.io.path]::GetTempPath())Pester-Tests\$([guid]::newguid().tostring())"

Import-Module "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\RemoveSidHistory.psd1"



Describe "Simple Translation" {
    It "Build root directory" {
        (New-Item -Type Directory "$PesterBaseTestPath").FullName | Should be $PesterBaseTestPath
        & 'icacls' "$PesterBaseTestPath" '/grant' '*BU:(CI)(OI)(F)'|Select -Skip 1 | Should BeLike "*Successfully processed 1 files; Failed processing 0 files*"
    }
    It "Setup Translation table for tests" {
        Add-TranslationTableEntry -SourceSID 'DU' -DestinationSID 'BU'
        Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
        Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'S-1-5-21-1-2-3-502'
    }
    It "Build non recursive directories" {
        $RSHTest='non-req'
        (New-Item -Type Directory "$PesterBaseTestPath\$RSHTest\Level2\Level3").FullName | Should be "$PesterBaseTestPath\$RSHTest\Level2\Level3"
        $tempacl = New-Object System.Security.AccessControl.Directorysecurity
        $tempacl.SetSecurityDescriptorSddlForm('O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-4)')
        (Get-Item "$PesterBaseTestPath\$RSHTest").SetAccessControl($tempacl)
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest").SDDL | Should Be "O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-4)"
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-4)"
        $tempacl.SetSecurityDescriptorSddlForm('O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)')
        (Get-Item "$PesterBaseTestPath\$RSHTest\Level2").SetAccessControl($tempacl)
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-4)"
    }
    It "Convert level1" {
        $RSHTest='non-req'
        Convert-FileSystem -Path "$PesterBaseTestPath\$RSHTest" -ChangeGroup -ChangeOwner
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest").SDDL | Should Be "O:BAG:BUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-502)"
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-502)"
    }
    It "Convert level2" {
        $RSHTest='non-req'
        Convert-FileSystem -Path "$PesterBaseTestPath\$RSHTest\Level2" -ChangeGroup -ChangeOwner
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:BUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-502)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-502)"
    }
    It "Build recursive directories" {
        $RSHTest='req'
        (New-Item -Type Directory "$PesterBaseTestPath\$RSHTest\Level2\Level3").FullName | Should be "$PesterBaseTestPath\$RSHTest\Level2\Level3"
        $tempacl = New-Object System.Security.AccessControl.Directorysecurity
        $tempacl.SetSecurityDescriptorSddlForm('O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-4)')
        (Get-Item "$PesterBaseTestPath\$RSHTest").SetAccessControl($tempacl)
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest").SDDL | Should Be "O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-4)"
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-4)"
        $tempacl.SetSecurityDescriptorSddlForm('O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)')
        (Get-Item "$PesterBaseTestPath\$RSHTest\Level2").SetAccessControl($tempacl)
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-4)"
    }
    It "Convert reqursively" {
        $RSHTest='req'
        Convert-FileSystem -Path "$PesterBaseTestPath\$RSHTest" -Recurse -ChangeGroup -ChangeOwner
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest").SDDL | Should Be "O:BAG:BUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-502)"
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:BUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-502)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-502)"
    }
    It "Build no change group" {
        $RSHTest='nochangegroup'
        (New-Item -Type Directory "$PesterBaseTestPath\$RSHTest\Level2\Level3").FullName | Should be "$PesterBaseTestPath\$RSHTest\Level2\Level3"
        $tempacl = New-Object System.Security.AccessControl.Directorysecurity
        $tempacl.SetSecurityDescriptorSddlForm('O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-4)')
        (Get-Item "$PesterBaseTestPath\$RSHTest").SetAccessControl($tempacl)
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest").SDDL | Should Be "O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-4)"
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-4)"
        $tempacl.SetSecurityDescriptorSddlForm('O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)')
        (Get-Item "$PesterBaseTestPath\$RSHTest\Level2").SetAccessControl($tempacl)
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-4)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-4)"
    }
    It "Convert without -ChangeOwner" {
        $RSHTest='nochangegroup'
        Convert-FileSystem -Path "$PesterBaseTestPath\$RSHTest" -ChangeOwner -Recurse
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest").SDDL | Should Be "O:BAG:DUD:PAI(A;OICI;FA;;;AU)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;S-1-5-21-1-2-3-502)"
        (Get-ACL -Literalpath "$PesterBaseTestPath\$RSHTest\Level2").SDDL | Should Be "O:BAG:DUD:AI(A;OICI;FA;;;S-1-5-21-1-2-3-502)(A;OICIID;FA;;;AU)(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;0x1200a9;;;S-1-5-21-1-2-3-502)"
    }
    It "Remove base test directory and all directories below" {
        Remove-Item -Recurse $PesterBaseTestPath
        Test-Path $PesterBaseTestPath | Should be $False
    }
}