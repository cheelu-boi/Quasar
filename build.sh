#!/bin/bash
set -e

echo "=== Step 1: Creating Local Output Directory Structure ==="
mkdir -p build_output/Server
mkdir -p build_output/Client

echo "=== Step 2: Downloading Mono Signing Key over HTTPS ==="
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Download the key cleanly via HTTPS directly to the modern keyring directory
sudo curl -fsSL "https://mono-project.com" -o /usr/share/keyrings/mono-official-archive-keyring.gpg

# Detect Ubuntu codename and map repository using the secure keyring
UBUNTU_CODENAME=$(lsb_release -cs)
echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://mono-project.com stable-$UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

echo "=== Step 3: Installing MSBuild and Mono Compiler ==="
sudo apt-get update
sudo apt-get install -y msbuild mono-roslyn mono-complete

echo "=== Step 4: Restoring Project Dependencies ==="
if [ -f "Quasar.sln" ]; then
    msbuild /t:Restore Quasar.sln
else
    echo "ERROR: Quasar.sln not found in the current directory!"
    exit 1
fi

echo "=== Step 5: Compiling the Solution ==="
msbuild Quasar.sln /p:Configuration=Release

echo "=== Step 6: Organizing Binaries into Output Subdirectories ==="
if [ -d "Quasar-Server/bin/Release" ]; then
    cp -r Quasar-Server/bin/Release/* build_output/Server/
fi
if [ -d "Quasar-Client/bin/Release" ]; then
    cp -r Quasar-Client/bin/Release/* build_output/Client/
fi

echo "============================================="
echo "BUILD PROCESS COMPLETE!"
echo "Your local compiled files are located in:"
echo "-> ./build_output/Server/"
echo "-> ./build_output/Client/"
echo "============================================="
