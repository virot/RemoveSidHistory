Import-Module "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\RemoveSidHistory.psd1"

Describe "TranslationTable" {
    It "Basic simple TranslationTable things" {
         Clear-TranslationTable
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
         Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'AU'
         (Get-TranslationTable).Count | Should Be '3'
         (Get-TranslationTable)['BU'] | Should Be 'DU'
         (Get-TranslationTable)['DU'] | Should Be $Null
         (Get-TranslationTable).ContainsKey('BU') | Should Be $True
         (Get-TranslationTable).ContainsKey('DU') | Should Be $False
         (Get-TranslationTable).ContainsKey('S-1-0-0') | Should Be $True
         Remove-TranslationTableEntry -Source 'S-1-0-0'
         (Get-TranslationTable).ContainsKey('S-1-0-0') | Should Be $False

    }
    It "Verify double steps" {
         Clear-TranslationTable
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'DU' -DestinationSID 'DA'
         (Get-TranslationTable).Count | Should Be '2'
         (Get-TranslationTable)['BU'] | Should Be 'DA'
         (Get-TranslationTable)['DU'] | Should Be 'DA'
         (Get-TranslationTable).ContainsKey('BU') | Should Be $True
         (Get-TranslationTable).ContainsKey('DU') | Should Be $True
         (Get-TranslationTable).ContainsKey('BA') | Should Be $False
    }
    It "Verify loop protection" {
         trap {continue}
         Clear-TranslationTable
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'DU' -DestinationSID 'BU' | Should Throw
         (Get-TranslationTable).Count | Should Be '1'
         (Get-TranslationTable)['BU'] | Should Be 'DU'
         (Get-TranslationTable).ContainsKey('DU') | Should Be $False
    }
    It "Verify loop double step protection" {
         trap {continue}
         Clear-TranslationTable
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DA'
         Add-TranslationTableEntry -SourceSID 'DA' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'DU' -DestinationSID 'BU' | Should Throw
         (Get-TranslationTable).Count | Should Be '2'
         (Get-TranslationTable).ContainsKey('DU') | Should Be $False
    }
    It "Export TranslationTable" {
         Clear-TranslationTable
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
         Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'AU'
         $tempfile = [system.io.path]::GetTempFileName()
         Export-TranslationTable -Path $tempfile
         (Get-FileHash $tempfile -Algorithm SHA1).Hash | Should Be 'C6349F2A72774BE241AC860BB75F85ABBEB1AEDB'
         Remove-Item $tempfile
    }
    It "Clear TranslationTable" {
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
         Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'AU'
         (Get-TranslationTable).Count | Should Be '3'
         Clear-TranslationTable
         (Get-TranslationTable).Count | Should Be '0'
    }
    It "Import TranslationTable" {
         $tempfile = [system.io.path]::GetTempFileName()
         @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>System.Collections.Hashtable</T>
      <T>System.Object</T>
    </TN>
    <DCT>
      <En>
        <S N="Key">S-1-0-0</S>
        <S N="Value">DA</S>
      </En>
      <En>
        <S N="Key">S-1-5-21-1-2-3-4</S>
        <S N="Value">AU</S>
      </En>
      <En>
        <S N="Key">BU</S>
        <S N="Value">DU</S>
      </En>
    </DCT>
  </Obj>
</Objs>
'@ | Set-Content $tempfile
         Import-TranslationTable -Path $tempfile
         (Get-TranslationTable).Count | Should Be '3'
         (Get-TranslationTable)['BU'] | Should Be 'DU'
         (Get-TranslationTable)['DU'] | Should Be $Null
         (Get-TranslationTable).ContainsKey('BU') | Should Be $True
         (Get-TranslationTable).ContainsKey('DU') | Should Be $False
         Remove-Item $tempfile
    }

    It "Add WellKnown SIDs" {
         Clear-TranslationTable
         Add-TranslationTableWellKnownSids -SourceBaseSID 'S-1-5-21-0-0-0' -DestinationBaseSID 'S-1-5-21-1-1-1'
         (Get-TranslationTable).Count | Should Be '11'
         (Get-TranslationTable)['S-1-5-21-0-0-0-512'] | Should Be 'S-1-5-21-1-1-1-512'
    }

}
