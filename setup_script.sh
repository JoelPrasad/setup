#!/bin/bash

# List of scripts to execute
scripts=("lvm.sh" "update_upgrade.sh" "qemu_guest_agent.sh" "clamAV.sh" "static_ips.sh")

# Maximum number of retries for each script
max_retries=2

# Function to execute a script with retry mechanism
execute_with_retry() {
    local script="$1"
    local attempts=0
    
    # Check if the corresponding service is running
    service_name="${script%.sh}"  # Assuming the service name matches the script name
    if sudo systemctl is-active --quiet "$service_name"; then
        echo "$service_name is already running. Skipping $script."
        return 0
    fi
    
    # Retry mechanism if the service is not running
    while (( attempts < max_retries )); do
        ./"$script"
        if [ $? -eq 0 ]; then
            echo "$script executed successfully."
            return 0  # Exit the function if successful
        else
            echo "Error executing $script. Retrying... ($((attempts+1))/$max_retries)"
            ((attempts++))
        fi
    done

    echo "Failed to execute $script after $max_retries attempts."
    return 1
}

# Loop through each script
for script in "${scripts[@]}"; do
    # Change permissions to +x
    chmod +x "$script"

    if [ "$script" == "lvm.sh" ]; then
        # Execute lvm.sh without stopping on failure, but check service status first
        service_name="lvm"
        if sudo systemctl is-active --quiet "$service_name"; then
            echo "$service_name is already running. Skipping $script."
            continue
        fi
        
        # Execute lvm.sh
        ./"$script"
        if [ $? -ne 0 ]; then
            echo "Warning: $script failed. Continuing to next script."
        else
            echo "$script executed successfully."
        fi
    else
        # Execute other scripts with retry mechanism
        if ! execute_with_retry "$script"; then
            echo "Continuing to next script despite failure of $script."
        fi
    fi
done

echo "All scripts executed."
