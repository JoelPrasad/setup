#!/bin/bash

# List of scripts to execute
scripts=("lvm.sh" "update_upgrade.sh" "qemu_guest_agent.sh" "static_ips.sh" "clamAV.sh")

# Loop through each script
for script in "${scripts[@]}"; do
    # Change permissions to +x
    chmod +x "$script"
    
    # Execute the script
    ./"$script"
    
    # Check if the previous command was successful
    if [ $? -ne 0 ]; then
        echo "Error executing $script. Exiting."
        exit 1
    fi
done

echo "All scripts executed successfully."
