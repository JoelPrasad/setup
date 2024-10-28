#!/bin/bash

# Function to check for YAML files in /etc/netplan/
check_yaml_files() {
    echo "Checking for YAML files in /etc/netplan..."
    yaml_files=("/etc/netplan/"*.yaml)

    if [ -e "${yaml_files[0]}" ]; then
        echo "YAML files found in /etc/netplan:"
        ls "${yaml_files[@]}"
        echo "Using the first YAML file found: ${yaml_files[0]}"
        update_netplan "${yaml_files[0]}"
    else
        echo "No YAML files found in /etc/netplan."
    fi
}

# Function to update netplan configuration
update_netplan() {
    local yaml_file="$1"

    echo "Enter the new static IP address (e.g., 192.168.100.10):"
    read -r new_ip

    # Verify the input IP format
    if [[ ! "$new_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid IP address format. Please enter a valid IP address."
        exit 1
    fi

    # Append /24 subnet mask automatically
    local new_ip_with_mask="${new_ip}/24"

    echo "Creating new netplan configuration..."

    # Check if the DNS server is reachable
    local dns_server="192.168.100.10"
    if ping -c 1 "$dns_server" &> /dev/null; then
        echo "DNS server $dns_server is reachable. Assigning as primary DNS."
        dns_config=("$dns_server" "8.8.8.8" "1.1.1.1")
        echo "Connection details:"
        echo "  DNS Server: $dns_server"
        echo "  Status: Reachable"
    else
        echo "DNS server $dns_server is not reachable. Using fallback DNS servers."
        dns_config=("8.8.8.8" "1.1.1.1" "8.8.4.4")
        echo "Connection details:"
        echo "  DNS Server: $dns_server"
        echo "  Status: Not Reachable"
    fi

    # Make a backup of the original YAML file (optional)
    sudo cp "$yaml_file" "$yaml_file.bak"

    # Capture permissions of the old YAML file
    local old_permissions
    old_permissions=$(stat -c "%a" "$yaml_file")

    # Delete the old YAML file
    sudo rm "$yaml_file"

    # Create the new YAML file with the same name as the old one
    {
        echo "# This file is generated from information provided by the datasource.  Changes"
        echo "# to it will not persist across an instance reboot.  To disable cloud-init's"
        echo "# network configuration capabilities, write a file" 
        echo "# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:"
        echo "# network: {config: disabled}"
        echo "network:"
        echo "    ethernets:"
        echo "        ens18:"
        echo "            dhcp4: false"
        echo "            addresses:"
        echo "              - $new_ip_with_mask"
        echo "            routes:"
        echo "                - to: 0.0.0.0/0"
        echo "                  via: 192.168.100.1"
        echo "            nameservers:"
        echo "                addresses:"
        for dns in "${dns_config[@]}"; do
            echo "                    - $dns"
        done
        echo "    version: 2"
    } | sudo tee "$yaml_file" >/dev/null

    # Restore permissions of the new file to match the original
    sudo chmod "$old_permissions" "$yaml_file"

    # Check if the new YAML file was created successfully
    if [ $? -eq 0 ]; then
        echo "Netplan configuration updated successfully in $yaml_file."
        
        # Apply the netplan configuration
        echo "Applying the netplan configuration..."
        sudo netplan apply
        if [ $? -eq 0 ]; then
            echo "Netplan configuration applied successfully."
        else
            echo "Failed to apply netplan configuration."
        fi
    else
        echo "Failed to create the new netplan configuration."
    fi
}

# Check if the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges."
    echo "Please enter your password to continue..."
    sudo -v  # Prompt for the password
    if [ $? -ne 0 ]; then
        echo "Failed to obtain root privileges. Exiting."
        exit 1
    fi
fi

# Call the function to check for YAML files and update netplan
check_yaml_files
