#!/bin/bash
set -e

echo "=== Step 1: Writing the GitHub Cloud Builder Recipe ==="
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

echo "=== Step 2: Forcing Push to GitHub Cloud ==="
git add .
git commit -m "Force cloud build configuration" || echo "No changes to commit"
git push origin master --force

echo "=== Step 3: Cleaning Temp Folders ==="
find . -type d \( -name "bin" -o -name "obj" \) -exec rm -rf {} + 2>/dev/null || true

echo "=== Step 4: Creating Your Clean ZIP File ==="
sudo apt-get update && sudo apt-get install -y zip
cd ..
zip -r Quasar_Submission.zip "$(basename "$OLDPWD")" -x "*.git*"
mv Quasar_Submission.zip "$OLDPWD/"
cd "$OLDPWD"

echo "=========================================================="
echo "SUCCESS!"
echo "1. Code pushed to Cloud: https://github.com"
echo "2. Local archive created: ./Quasar_Submission.zip"
echo "=========================================================="
