#!/usr/bin/env bash
# install-claude.sh — macOS / Linux symlink installer for claude-dotfiles v1.1
#
# Creates:
#   ~/.claude/commands/<skill>.md -> ~/.dotfiles/skills/<skill>/SKILL.md (per skill directory)
#   ~/.claude/agents/<agent>.md   -> ~/.dotfiles/agents/<agent>.md      (per agent file)
#
# Re-running is safe — overwrites existing symlinks. Re-run when skills or agents
# are added / removed / renamed.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
COMMANDS_DIR="$CLAUDE_DIR/commands"
AGENTS_DIR="$CLAUDE_DIR/agents"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "Error: dotfiles directory not found at $DOTFILES_DIR" >&2
  echo "Clone the repo there, or set DOTFILES_DIR to its location." >&2
  exit 1
fi

mkdir -p "$COMMANDS_DIR" "$AGENTS_DIR"

echo "Installing skills as commands..."
skill_count=0
for skill_dir in "$DOTFILES_DIR/skills/"*/; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  if [[ -f "$skill_file" ]]; then
    target="$COMMANDS_DIR/$skill_name.md"
    ln -sfn "$skill_file" "$target"
    echo "  $skill_name -> $skill_file"
    skill_count=$((skill_count + 1))
  fi
done

echo "Installing agents..."
agent_count=0
for agent_file in "$DOTFILES_DIR/agents/"*.md; do
  if [[ -f "$agent_file" ]]; then
    agent_name="$(basename "$agent_file")"
    target="$AGENTS_DIR/$agent_name"
    ln -sfn "$agent_file" "$target"
    echo "  $agent_name -> $agent_file"
    agent_count=$((agent_count + 1))
  fi
done

echo
echo "Installed $skill_count skills and $agent_count agents."
echo "Dotfiles at: $DOTFILES_DIR"
echo "Claude config at: $CLAUDE_DIR"
echo
echo "Symlinks point at the live files; 'git pull' on the dotfiles propagates without re-running."
