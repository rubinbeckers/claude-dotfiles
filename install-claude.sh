#!/usr/bin/env bash
#
# install-claude.sh
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
# Works on macOS and Linux. The Windows equivalent is install-claude.ps1.

set -euo pipefail

dotfiles="${HOME}/.dotfiles"
commands_dir="${HOME}/.claude/commands"
agents_dir="${HOME}/.claude/agents"

mkdir -p "${commands_dir}" "${agents_dir}"

# --- Skills: one per directory, each with SKILL.md ---
skill_count=0
for skill_path in "${dotfiles}"/skills/*/; do
  [ -d "${skill_path}" ] || continue
  skill_file="${skill_path}SKILL.md"
  skill_name="$(basename "${skill_path}")"
  link_path="${commands_dir}/${skill_name}.md"

  if [ -f "${skill_file}" ]; then
    ln -sf "${skill_file}" "${link_path}"
    echo "Linked skill:  ${skill_name}"
    skill_count=$((skill_count + 1))
  fi
done

# --- Agents: one .md file each, flat layout under agents/ ---
agent_count=0
if [ -d "${dotfiles}/agents" ]; then
  for agent_file in "${dotfiles}"/agents/*.md; do
    [ -f "${agent_file}" ] || continue
    agent_name="$(basename "${agent_file}")"
    link_path="${agents_dir}/${agent_name}"

    ln -sf "${agent_file}" "${link_path}"
    echo "Linked agent:  ${agent_name%.md}"
    agent_count=$((agent_count + 1))
  done
fi

echo ""
echo "Done. ${skill_count} skills linked, ${agent_count} agents linked."
