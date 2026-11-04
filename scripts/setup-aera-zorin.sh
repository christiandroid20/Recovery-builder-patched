#!/usr/bin/env bash
set -Eeuo pipefail

# One-time prerequisite setup for the AERA A35x self-hosted runner on Zorin OS 18.
# Run this manually from the Zorin desktop account before registering the runner.

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: This setup expects an x86_64 Linux installation."
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "ERROR: Cannot identify the Linux distribution."
  exit 1
fi

. /etc/os-release
if [[ "${ID:-}" != "zorin" ]]; then
  echo "WARNING: Detected ${PRETTY_NAME:-unknown}. This script was prepared for Zorin OS 18."
fi

echo "Detected OS: ${PRETTY_NAME:-unknown}"
echo "Installing AERA / Android recovery build dependencies..."

sudo apt-get update
sudo apt-get install -y \
  git git-lfs gnupg curl wget aria2 \
  python3 python-is-python3 \
  openjdk-21-jdk \
  bc bison build-essential flex \
  g++-multilib gcc-multilib libc6-dev-i386 \
  lib32gcc-s1 lib32stdc++6 lib32z1 lib32z1-dev \
  lib32ncurses-dev libncurses-dev \
  libssl-dev libelf-dev \
  libxml2-utils libxml2-dev xsltproc \
  zlib1g-dev liblz4-tool lz4 \
  zip unzip rsync ccache \
  pngcrush schedtool squashfs-tools \
  gperf libgl1-mesa-dev libx11-dev x11proto-core-dev \
  fontconfig

echo
echo "Checking Java..."
java -version 2>&1
if ! java -version 2>&1 | grep -q 'version "21'; then
  echo "ERROR: JDK 21 is installed but is not the active Java version."
  echo "Select Java 21 with: sudo update-alternatives --config java"
  exit 1
fi

mkdir -p "$HOME/bin" "$HOME/.cache/ccache" "$HOME/aera-build"
ccache -M 20G

echo
echo "=== Disk and memory ==="
df -h "$HOME" "$HOME/aera-build"
free -h
swapon --show || true

echo
echo "=== ccache ==="
ccache -s

echo
echo "AERA build prerequisites installed."
echo "Next: register the self-hosted runner from GitHub repository Settings > Actions > Runners."
echo "Use the custom runner label: a35x-builder"
