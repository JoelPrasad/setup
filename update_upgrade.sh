#!/bin/bash

# Determine if we need sudo
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# Script to update and upgrade Ubuntu 24.04
echo "Updating package list..."
$SUDO apt update

echo "Upgrading installed packages..."
$SUDO apt upgrade -y

echo "Dist-upgrading packages..."
$SUDO apt dist-upgrade -y

echo "Cleaning up..."
$SUDO apt autoremove -y

echo "Update and upgrade completed successfully."
