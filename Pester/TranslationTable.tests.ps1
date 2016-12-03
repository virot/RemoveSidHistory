Import-Module "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\RemoveSidHistory.psd1"

Describe "TranslationTable" {
    It "Add simple TranslationTable things" {
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
         Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'AU'
         (Get-TranslationTable).Count | Should Be '3'
         (Get-TranslationTable)['BU'] | Should Be 'DU'
         (Get-TranslationTable)['DU'] | Should Be $Null
         (Get-TranslationTable).ContainsKey('BU') | Should Be $True
         (Get-TranslationTable).ContainsKey('DU') | Should Be $False
    }
    It "Clear TranslationTable" {
         Add-TranslationTableEntry -SourceSID 'BU' -DestinationSID 'DU'
         Add-TranslationTableEntry -SourceSID 'S-1-0-0' -DestinationSID 'DA'
         Add-TranslationTableEntry -SourceSID 'S-1-5-21-1-2-3-4' -DestinationSID 'AU'
         (Get-TranslationTable).Count | Should Be '3'
         Clear-TranslationTable
         (Get-TranslationTable).Count | Should Be '0'
    }
}
