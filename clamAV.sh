#!/bin/bash

# Function to check if the script is running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "This script requires root privileges. Please enter your password."
        exec sudo "$0" "$@"
        exit 1
    fi
}

# Check if running as root
check_root "$@"

# Install ClamAV
echo "Installing ClamAV..."
apt update -y
apt install -y clamav clamav-daemon

# Update ClamAV database
echo "Updating ClamAV database..."
if ! freshclam; then
    echo "Error updating ClamAV database. Trying to troubleshoot..."
    
    # Troubleshooting steps
    echo "Performing ClamAV troubleshooting steps..."
    
    # Step 1: Ensure no other instance of 'freshclam' is running
    echo "1. Ensuring no other instance of 'freshclam' is running..."
    killall freshclam 2>/dev/null || echo "No running instances of 'freshclam' to kill."

    # Step 2: Check permissions for /var/lib/clamav
    echo "2. Checking permissions for /var/lib/clamav..."
    ls -ld /var/lib/clamav || echo "Failed to check permissions."

    # Step 3: Check for proxy configuration
    echo "3. If using a proxy, ensure it is configured in /etc/clamav/freshclam.conf."
    echo "   You can check this file with: nano /etc/clamav/freshclam.conf"
    
    # Step 4: Check logs for detailed error messages
    echo "4. Checking freshclam log for errors..."
    if [ -f /var/log/clamav/freshclam.log ]; then
        echo "Freshclam log:"
        tail -n 20 /var/log/clamav/freshclam.log
    else
        echo "Freshclam log not found. Please check your ClamAV installation."
    fi
    
    exit 1
fi

# Start and enable ClamAV services
echo "Enabling and starting ClamAV service..."
systemctl enable clamav-daemon
systemctl start clamav-daemon

# Verify the service status
echo "Checking ClamAV service status..."
systemctl status clamav-daemon

# Setup a cron job to run ClamAV daily at 00:01
CRON_JOB="1 0 * * * /usr/bin/sudo /usr/bin/clamscan -r --bell -i /"
echo "Setting up daily cron job for ClamAV..."

# Check if the cron job already exists
if ! crontab -l | grep -q "/usr/bin/sudo /usr/bin/clamscan"; then
    (crontab -l; echo "$CRON_JOB") | crontab -
    echo "Cron job added to run ClamAV scan daily at 00:01."
else
    echo "Cron job already exists."
fi

# Display the current cron jobs
echo "Current cron jobs:"
crontab -l

echo "ClamAV installation and setup completed successfully."
