#!/usr/bin/env bash
#
# E3 Hackathon — create a fresh team project folder from the starter template.
#
# Copies starter/ (commands, plugins, AGENTS.md, welcome page) into a new
# folder with NO git history — the team's own /setup command initializes git
# and publishes to the E3 org from inside opencode.
#
# Usage (from anywhere inside the cloned e3-hackathon repo):
#   bash setup/new-project.sh mama-lishe-orders
#   bash setup/new-project.sh mama-lishe-orders ~/projects

set -euo pipefail

NAME="${1:-}"
DEST="${2:-$HOME/Desktop}"

if [[ -z "$NAME" ]]; then
  echo "Usage: bash setup/new-project.sh <project-name> [destination-dir]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/../starter"
TARGET="$DEST/$NAME"

if [[ ! -d "$SOURCE" ]]; then
  echo "Cannot find the starter template at $SOURCE — run this from the cloned e3-hackathon repo." >&2
  exit 1
fi
if [[ -e "$TARGET" ]]; then
  echo "$TARGET already exists — pick another name or move the old folder first." >&2
  exit 1
fi

mkdir -p "$DEST"
cp -R "$SOURCE" "$TARGET"

echo ""
echo "Team project created: $TARGET"
echo ""
echo "Next steps for the team:"
echo "  1. cd \"$TARGET\""
echo "  2. opencode"
echo "  3. type /setup and follow along"
