#!/bin/bash
set -e

echo "=== Step 1: Cleaning Broken Mono Repositories ==="
# Removes the invalid repository list that caused the 404 error
sudo rm -f /etc/apt/sources.list.d/mono-official-stable.list

echo "=== Step 2: Syncing Package Lists ==="
sudo apt-get update

echo "=== Step 3: Installing GitHub CLI ==="
if ! command -v gh &> /dev/null; then
    sudo apt-get install -y gh
fi

echo "=== Step 4: Verification of GitHub Login ==="
if ! gh auth status &> /dev/null; then
    echo "Please interact with the terminal prompts to log into GitHub:"
    gh auth login --web -h github.com
fi

echo "=== Step 5: Initializing Git and Building Workflow Structure ==="
if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

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

echo "=== Step 6: Spinning Up Remote Repository and Pushing ==="
REPO_NAME=$(basename "$PWD")
# Creates a private cloud workspace directly on your GitHub account
gh repo create "$REPO_NAME" --private --source=. --remote=origin || echo "Repository already initialized on account, moving forward..."

git add .
git commit -m "Deploy pristine cloud compilation layout" || echo "Nothing new to commit"
git push -u origin main

echo "=========================================================="
echo "SUCCESS! Broken local paths resolved."
echo "Your cloud compilation pipeline is now starting live at:"
gh repo view --web
echo "=========================================================="
