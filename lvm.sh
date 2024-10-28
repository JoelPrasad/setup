#!/bin/bash

# Function to check if the command requires sudo
run_with_sudo() {
    if [ "$EUID" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# Extend the logical volume to use all free space
run_with_sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# Check if the lvextend command was successful
if [ $? -eq 0 ]; then
    echo "Logical volume extended successfully."
else
    echo "Failed to extend the logical volume." >&2
    exit 1
fi

# Resize the filesystem
run_with_sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

# Check if the resize2fs command was successful
if [ $? -eq 0 ]; then
    echo "Filesystem resized successfully."
else
    echo "Failed to resize the filesystem." >&2
    exit 1
fi
