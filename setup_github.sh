#!/bin/bash
set -e

# 1. Install GitHub CLI if missing
if ! command -v gh &> /dev/null; then
    echo "=== Step 1: Installing GitHub CLI ==="
    sudo apt-get update
    sudo apt-get install -y gh
fi

# 2. Check Authentication
echo "=== Step 2: Checking GitHub Authentication ==="
if ! gh auth status &> /dev/null; then
    echo "You need to log into GitHub first. Please follow the terminal prompts:"
    gh auth login --web -h github.com
fi

# 3. Initialize git locally if not already done
if [ ! -d ".git" ]; then
    echo "=== Step 3: Initializing Local Git Repository ==="
    git init
    git branch -M main
fi

# 4. Create the GitHub Actions Workflow file
echo "=== Step 4: Generating Cloud Build Workflow ==="
mkdir -p .github/workflows
cat << 'WORKFLOW' > .github/workflows/build.yml
name: Build Windows UI App

on: 
  push:
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-latest  # Forces the cloud to use Windows with all desktop SDKs

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

# 5. Create the Remote Repository on GitHub website automatically
echo "=== Step 5: Automatically Generating GitHub Repository Online ==="
# Extracts current directory name to name the repository
REPO_NAME=$(basename "$PWD")
gh repo create "$REPO_NAME" --private --source=. --remote=origin || echo "Repository might already exist online, skipping creation..."

# 6. Commit and Push everything to trigger the build
echo "=== Step 6: Pushing Code to Trigger Cloud Build ==="
git add .
git commit -m "Configure cloud compilation workflow" || echo "No changes to commit"
git push -u origin main

echo "=========================================================="
echo "SUCCESS: Repository created and code pushed!"
echo "Go to your web browser to watch it build live:"
gh repo view --web
echo "=========================================================="
