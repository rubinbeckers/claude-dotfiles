# install-claude.ps1
#
# Symlinks the agentic-SDLC workflow v1.0 dotfiles into Claude Code's
# user-level discovery directories:
#   ~/.dotfiles/skills/<skill>/SKILL.md  →  ~/.claude/commands/<skill>.md
#   ~/.dotfiles/agents/<agent>.md        →  ~/.claude/agents/<agent>.md
#
# Run on first install of the dotfiles and any time skills/agents are added
# or renamed. Symlinks point at the live files in this repo, so updates
# (e.g. `git pull` on the dotfiles) propagate without re-running this script.
#
# Windows note: creating symbolic links requires either Developer Mode
# enabled OR running PowerShell as Administrator.

$dotfiles    = "$env:USERPROFILE\.dotfiles"
$commandsDir = "$env:USERPROFILE\.claude\commands"
$agentsDir   = "$env:USERPROFILE\.claude\agents"

New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
New-Item -ItemType Directory -Path $agentsDir   -Force | Out-Null

# --- Skills: one per directory, each with SKILL.md ---
$skillCount = 0
Get-ChildItem "$dotfiles\skills" -Directory |
  ForEach-Object {
    $skillFile = Join-Path $_.FullName 'SKILL.md'
    $linkPath  = Join-Path $commandsDir "$($_.Name).md"

    if (Test-Path $skillFile) {
      if (Test-Path $linkPath) { Remove-Item $linkPath }
      New-Item -ItemType SymbolicLink -Path $linkPath -Target $skillFile | Out-Null
      Write-Host "Linked skill:  $($_.Name)"
      $skillCount++
    }
  }

# --- Agents: one .md file each, flat layout under agents/ ---
$agentCount = 0
if (Test-Path "$dotfiles\agents") {
  Get-ChildItem "$dotfiles\agents" -Filter '*.md' -File |
    ForEach-Object {
      $linkPath = Join-Path $agentsDir $_.Name

      if (Test-Path $linkPath) { Remove-Item $linkPath }
      New-Item -ItemType SymbolicLink -Path $linkPath -Target $_.FullName | Out-Null
      Write-Host "Linked agent:  $($_.BaseName)"
      $agentCount++
    }
}

Write-Host ""
Write-Host "Done. $skillCount skills linked, $agentCount agents linked."
