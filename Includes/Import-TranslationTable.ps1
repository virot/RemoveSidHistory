Function Import-TranslationTable {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Literalpath (Split-Path $_)})]
    [ValidateLength(1,260)]
    [string]
    $Path
    )
  Process
  {
    $script:TranslationTable = Import-CLIXML -LiteralPath $Path
  }
}