#!/bin/bash
set -e

echo "=== Step 1: Getting your GitHub Username ==="
# Automatically fetches your logged-in username from the 'gh' tool session
GH_USER=$(gh api user -q .login)
REPO_NAME=$(basename "$PWD")
echo "Authenticated as: $GH_USER"
echo "Repository Target: $REPO_NAME"

echo "=== Step 2: Re-routing Remote Links to Your Profile ==="
# Disconnects the original author's repository and maps it directly to yours
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com"

echo "=== Step 3: Setting Identity Fallbacks ==="
git config --global user.email "git-builder@cloud-compile.local"
git config --global user.name "Cloud Builder Machine"

echo "=== Step 4: Forcing Commit and Cloud Dispatch ==="
git add .
git commit -m "Deploy pristine cloud compilation layout" || echo "Code changes already staged"

# Pushes your local codebase up to your personal private cloud workspace
git push -u origin main --force

echo "=========================================================="
echo "SUCCESS: Code pushed to your personal profile!"
echo "Opening your browser to watch the cloud compile live..."
echo "=========================================================="
gh repo view --web
