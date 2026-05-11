$dotfiles  = "$env:USERPROFILE\.dotfiles"
$commands  = "$env:USERPROFILE\.claude\commands"

New-Item -ItemType Directory -Path $commands -Force | Out-Null

Get-ChildItem "$dotfiles\skills" -Directory |
  Where-Object { $_.Name -ne 'deprecated' } |
  ForEach-Object {
    $skillFile = Join-Path $_.FullName 'SKILL.md'
    $linkPath  = Join-Path $commands "$($_.Name).md"

    if (Test-Path $skillFile) {
      if (Test-Path $linkPath) { Remove-Item $linkPath }
      New-Item -ItemType SymbolicLink -Path $linkPath -Target $skillFile | Out-Null
      Write-Host "Linked: $($_.Name)"
    }
  }

Write-Host "`nDone. $(Get-ChildItem $commands -Filter '*.md' | Measure-Object | Select-Object -ExpandProperty Count) skills linked."