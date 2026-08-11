#!/bin/bash
set -e

echo "=== Step 1: Discovering Your GitHub Account ==="
# Automatically fetches your active logged-in username
GH_USER=$(gh api user -q .login)
# Names the new repository based on your current folder name
REPO_NAME=$(basename "$PWD")

echo "Hello $GH_USER, creating a fresh repository named: $REPO_NAME"

echo "=== Step 2: Wiping Old Git Ties ==="
# Deletes the original author's hidden tracking history completely
rm -rf .git

echo "=== Step 3: Initializing Your Clean Local Repository ==="
git init
git branch -M main

echo "=== Step 4: Setting Global Identity Details ==="
git config --global user.email "$GH_USER@://github.com"
git config --global user.name "$GH_USER"

echo "=== Step 5: Regenerating the Actions Build Workflow ==="
mkdir -p .github/workflows
cat << 'WORKFLOW' > .github/workflows/build.yml
name: Build Windows UI App

on: 
  push:
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Restore Dependencies
      run: dotnet restore Quasar.sln

    - name: Build Solution
      run: dotnet build Quasar.sln --configuration Release

    - name: Upload Compiled Application
      uses: actions/upload-artifact@v4
      with:
        name: Quasar-Windows-Build
        path: |
          **/bin/Release/
          **/bin/Debug/
WORKFLOW

echo "=== Step 6: Creating the Remote Private Repository Online ==="
# Instructs GitHub to make a fresh, empty private repository under your profile
gh repo create "$REPO_NAME" --private --source=. --remote=origin || echo "Repository already setup online, pointing directly to it..."

echo "=== Step 7: Committing Your Project Files ==="
git add .
git commit -m "Initial commit of solution files on a personal clean repo"

echo "=== Step 8: Pushing Code to Your Account ==="
git push -u origin main --force

echo "=========================================================="
echo "SUCCESS: Brand new repository created under your account!"
echo "Opening your dashboard. Click 'Actions' at the top to watch."
echo "=========================================================="
gh repo view --web
