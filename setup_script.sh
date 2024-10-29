#!/bin/bash

# List of scripts to execute
scripts=("lvm.sh" "update_upgrade.sh" "qemu_guest_agent.sh" "clamAV.sh" "static_ips.sh")

# Loop through each script
for script in "${scripts[@]}"; do
    # Change permissions to +x
    chmod +x "$script"

    if [ "$script" == "lvm.sh" ]; then
        # Execute lvm.sh without stopping on failure
        ./"$script"
        if [ $? -ne 0 ]; then
            echo "Warning: $script failed. Continuing to next script."
        else
            echo "$script executed successfully."
        fi
    else
        # Execute other scripts with retry mechanism
        while true; do
            ./"$script"
            if [ $? -eq 0 ]; then
                echo "$script executed successfully."
                break  # Exit the loop if the script succeeded
            else
                echo "Error executing $script. Retrying..."
            fi
        done
    fi
done

echo "All scripts executed."
