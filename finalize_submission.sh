#!/bin/bash
set -e

# Configuration
SOLUTION_FILE="Quasar.sln"
SUBMISSION_ZIP="Quasar_Submission.zip"
TARGET_BRANCH="master"

echo "=========================================================="
echo "          STARTING SUBMISSION PACKAGING PROCESS           "
echo "=========================================================="

echo -e "\n=== [Step 1] Running Local CLI Build Verification ==="
if command -v dotnet &> /dev/null; then
    echo "Compiling Release configuration with dotnet..."
    dotnet build "$SOLUTION_FILE" -c Release
elif command -v msbuild &> /dev/null; then
    echo "Compiling Release configuration with msbuild..."
    msbuild "$SOLUTION_FILE" /p:Configuration=Release
else
    echo "⚠️ Warning: No local .NET compiler found. Skipping build verification."
fi

echo -e "\n=== [Step 2] Cleaning Build Artifacts ==="
if command -v dotnet &> /dev/null; then
    echo "Running dotnet clean..."
    dotnet clean "$SOLUTION_FILE" || true
fi

echo "Purging temporary bin and obj folders..."
find . -type d \( -name "bin" -o -name "obj" \) -exec rm -rf {} + 2>/dev/null || true

echo -e "\n=== [Step 3] Generating Clean Delivery Archive ==="
if ! command -v zip &> /dev/null; then
    echo "Installing missing 'zip' utility..."
    sudo apt-get update && sudo apt-get install -y zip
fi

# Capture local path variables cleanly
WORKING_DIR=$(pwd)
PROJECT_FOLDER=$(basename "$WORKING_DIR")

echo "Packaging directory '$PROJECT_FOLDER' into $SUBMISSION_ZIP..."
cd ..
zip -r "$SUBMISSION_ZIP" "$PROJECT_FOLDER" -x "$PROJECT_FOLDER/.git*"
mv "$SUBMISSION_ZIP" "$WORKING_DIR/"
cd "$WORKING_DIR"

echo -e "\n=== [Step 4] Staging, Committing, and Pushing to GitHub ==="
if [ -d ".git" ]; then
    git add .
    # Commit changes safely without crashing if nothing new is staged
    git commit -m "Finalize project submission" || echo "No new changes to commit."
    
    echo "Pushing updates to remote repository..."
    git push origin "$TARGET_BRANCH" --force
else
    echo "⚠️ Warning: Git repository not detected. Skipping GitHub deployment step."
fi

echo "=========================================================="
echo "🎉 SUBMISSION PACKAGING COMPLETE!"
echo "1. GitHub updated on branch: $TARGET_BRANCH"
echo "2. Local delivery archive created: ./$SUBMISSION_ZIP"
echo "=========================================================="
