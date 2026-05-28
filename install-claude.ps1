# install-claude.ps1 — Windows symlink installer for claude-dotfiles v1.1
#
# Creates:
#   $env:USERPROFILE\.claude\commands\<skill>.md -> $env:USERPROFILE\.dotfiles\skills\<skill>\SKILL.md
#   $env:USERPROFILE\.claude\agents\<agent>.md   -> $env:USERPROFILE\.dotfiles\agents\<agent>.md
#
# Requires Developer Mode enabled OR running PowerShell as Administrator
# (symlink creation on Windows is gated otherwise).
#
# Re-running is safe — overwrites existing symlinks.

$ErrorActionPreference = "Stop"

$DotfilesDir = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $env:USERPROFILE ".dotfiles" }
$ClaudeDir   = if ($env:CLAUDE_DIR)   { $env:CLAUDE_DIR }   else { Join-Path $env:USERPROFILE ".claude" }
$CommandsDir = Join-Path $ClaudeDir "commands"
$AgentsDir   = Join-Path $ClaudeDir "agents"

if (-not (Test-Path $DotfilesDir)) {
    Write-Error "Dotfiles directory not found at $DotfilesDir. Clone the repo there, or set `$env:DOTFILES_DIR."
    exit 1
}

New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsDir   | Out-Null

Write-Host "Installing skills as commands..."
$skillCount = 0
Get-ChildItem -Directory (Join-Path $DotfilesDir "skills") | ForEach-Object {
    $skillName = $_.Name
    $skillFile = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $skillFile) {
        $target = Join-Path $CommandsDir "$skillName.md"
        if (Test-Path $target) { Remove-Item $target -Force }
        New-Item -ItemType SymbolicLink -Path $target -Target $skillFile | Out-Null
        Write-Host "  $skillName -> $skillFile"
        $skillCount++
    }
}

Write-Host "Installing agents..."
$agentCount = 0
Get-ChildItem -File -Filter "*.md" (Join-Path $DotfilesDir "agents") | ForEach-Object {
    $agentName = $_.Name
    $agentFile = $_.FullName
    $target = Join-Path $AgentsDir $agentName
    if (Test-Path $target) { Remove-Item $target -Force }
    New-Item -ItemType SymbolicLink -Path $target -Target $agentFile | Out-Null
    Write-Host "  $agentName -> $agentFile"
    $agentCount++
}

Write-Host ""
Write-Host "Installed $skillCount skills and $agentCount agents."
Write-Host "Dotfiles at: $DotfilesDir"
Write-Host "Claude config at: $ClaudeDir"
Write-Host ""
Write-Host "Symlinks point at the live files; 'git pull' on the dotfiles propagates without re-running."
