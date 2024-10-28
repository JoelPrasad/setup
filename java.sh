#!/bin/bash

# Function to display available Java versions
display_versions() {
    echo "Available Java versions:"
    echo "1. OpenJDK 8"
    echo "2. OpenJDK 11"
    echo "3. OpenJDK 17"
    echo "4. OpenJDK 20"
}

# Function to install JRE
install_jre() {
    case $1 in
        1)
            echo "Installing OpenJDK 8 JRE..."
            sudo apt update
            sudo apt install -y openjdk-8-jre
            ;;
        2)
            echo "Installing OpenJDK 11 JRE..."
            sudo apt update
            sudo apt install -y openjdk-11-jre
            ;;
        3)
            echo "Installing OpenJDK 17 JRE..."
            sudo apt update
            sudo apt install -y openjdk-17-jre
            ;;
        4)
            echo "Installing OpenJDK 20 JRE..."
            sudo apt update
            sudo apt install -y openjdk-20-jre
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Function to install JDK
install_jdk() {
    case $1 in
        1)
            echo "Installing OpenJDK 8 JDK..."
            sudo apt update
            sudo apt install -y openjdk-8-jdk
            ;;
        2)
            echo "Installing OpenJDK 11 JDK..."
            sudo apt update
            sudo apt install -y openjdk-11-jdk
            ;;
        3)
            echo "Installing OpenJDK 17 JDK..."
            sudo apt update
            sudo apt install -y openjdk-17-jdk
            ;;
        4)
            echo "Installing OpenJDK 20 JDK..."
            sudo apt update
            sudo apt install -y openjdk-20-jdk
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Main script
echo "Welcome to the Java Installer!"
echo "Please choose whether you want to install JRE or JDK:"
echo "1. JRE"
echo "2. JDK"
read -p "Enter your choice (1 or 2): " java_choice

# Display available versions
display_versions

# Ask for the version
read -p "Please select the version you want (1-4): " version_choice

# Install based on user input
if [ "$java_choice" -eq 1 ]; then
    install_jre "$version_choice"
elif [ "$java_choice" -eq 2 ]; then
    install_jdk "$version_choice"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Verify the installation
echo "Java installation completed. Verifying installation..."
java -version
