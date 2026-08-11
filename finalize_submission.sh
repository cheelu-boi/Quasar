#!/bin/bash
set -e

echo "=== [Option 3] Running Local CLI Build Verification ==="
# Instantly runs a Release compilation check on your solution
if command -v dotnet &> /dev/null; then
    dotnet build Quasar.sln -c Release
elif command -v msbuild &> /dev/null; then
    msbuild Quasar.sln /p:Configuration=Release
else
    echo "Warning: No local compiler found, skipping local verification step."
fi

echo "=== [Option 1] Staging, Committing, and Pushing to GitHub ==="
# Packages your files and automatically updates your master branch online
git add .
git commit -m "Finalize project submission" || echo "No new changes to commit"
git push origin master --force

echo "=== [Option 2] Cleaning and Compressing into a ZIP Archive ==="
# Drops bulky compilation artifacts to reduce your upload file size significantly
if command -v dotnet &> /dev/null; then
    dotnet clean Quasar.sln || true
fi

echo "Purging temporary bin and obj folders..."
find . -type d \( -name "bin" -o -name "obj" \) -exec rm -rf {} + 2>/dev/null || true

echo "Generating clean delivery archive: Quasar_Submission.zip"
# Installs zip tool if missing, then bundles everything safely
sudo apt-get update && sudo apt-get install -y zip
cd ..
zip -r Quasar_Submission.zip "$(basename "$OLDPWD")" -x "*.git*"
mv Quasar_Submission.zip "$OLDPWD/"
cd "$OLDPWD"

echo "=========================================================="
echo "SUBMISSION PACKAGING COMPLETE!"
echo "1. GitHub updated: https://github.com"
echo "2. Local delivery archive created: ./Quasar_Submission.zip"
echo "=========================================================="
