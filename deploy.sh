#!/bin/bash
# ─────────────────────────────────────────────
#  Saba Fit — one-command deploy script
#  Usage: ./deploy.sh ~/Downloads/saba-fitness.zip
# ─────────────────────────────────────────────

REPO="$HOME/saba-fitness"
ZIP="${1:-$HOME/Downloads/saba-fitness.zip}"

if [ ! -f "$ZIP" ]; then
  echo "❌  Zip not found at: $ZIP"
  echo "    Usage: ./deploy.sh /path/to/saba-fitness.zip"
  exit 1
fi

echo "📦  Unzipping $ZIP..."
unzip -o "$ZIP" -d "$HOME" > /dev/null

echo "📁  Moving into repo..."
cd "$REPO" || { echo "❌  Repo not found at $REPO"; exit 1; }

echo "🔍  Changes:"
git status --short

echo "➕  Staging all changes..."
git add .

COMMIT_MSG="Update app $(date '+%b %d %H:%M')"
echo "💬  Committing: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

echo "🚀  Pushing to GitHub..."
git push

echo ""
echo "✅  Done! Live in ~60 seconds at your GitHub Pages URL."
