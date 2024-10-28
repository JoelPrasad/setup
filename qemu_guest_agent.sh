#!/bin/bash

# Determine if we need sudo
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# Install QEMU Guest Agent
echo "Installing QEMU Guest Agent..."
$SUDO apt update
$SUDO apt install -y qemu-guest-agent

# Enable and start the QEMU Guest Agent service
echo "Enabling and starting QEMU Guest Agent service..."
$SUDO systemctl enable qemu-guest-agent
$SUDO systemctl start qemu-guest-agent

# Verify the service status
echo "Checking QEMU Guest Agent service status..."
$SUDO systemctl status qemu-guest-agent

echo "QEMU Guest Agent installation and setup completed successfully."
