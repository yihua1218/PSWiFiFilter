#!/bin/bash

# macOSWiFiFilter - Wi-Fi SSID visibility management script for macOS
# MIT License - Copyright (c) 2025 WiFiFilter Contributors

# Note: On macOS, this script manages networks through the preferred networks list.
# Before using this script:
# 1. Open System Preferences > Network > Wi-Fi > Advanced
# 2. Add the networks you want to manage to your preferred networks list
# 3. Run this script to configure which networks should be visible

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run this script with sudo privileges${NC}"
    echo -e "${YELLOW}Usage: sudo $0${NC}"
    exit 1
fi

# Check for macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}This script is only for macOS systems${NC}"
    exit 1
fi

# Function to write error messages
write_error() {
    echo -e "${RED}$1${NC}"
}

# Function to write success messages
write_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to write warning messages
write_warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to show help
show_help() {
    cat << EOF
${CYAN}macOSWiFiFilter Help${NC}
${CYAN}==================${NC}
This script manages Wi-Fi network visibility on macOS.

${YELLOW}Before using this script:${NC}
1. Open System Preferences > Network > Wi-Fi > Advanced
2. Add all networks you want to manage to your preferred networks list
3. Run this script to configure which networks should be visible

${CYAN}Usage:${NC}
  sudo $0        Run the script normally
  sudo $0 -h     Show this help message

${CYAN}Files:${NC}
  allowed_ssids.txt   List of networks to keep visible
  hidden_ssids.txt    List of networks that were hidden

${CYAN}The script will:${NC}
- Read your preferred networks list
- Let you choose which networks to keep visible
- Save your choices for future use
- Maintain a list of hidden networks

${YELLOW}Note:${NC} This script uses macOS's network preferences system.
All networks must be added to System Preferences before they can be managed.
EOF
    exit 0
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Function to check system requirements
check_system_requirements() {
    # Check if networksetup is available
    if ! command -v networksetup >/dev/null 2>&1; then
        write_error "networksetup command not found. This script requires macOS network utilities."
        exit 1
    fi
    
    # Check if System Preferences can be accessed
    if ! networksetup -listallnetworkservices >/dev/null 2>&1; then
        write_error "Cannot access network settings. Please check your permissions."
        exit 1
    fi
}

# Function to get Wi-Fi interface name
get_wifi_interface() {
    local interface
    interface=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
    if [ -z "$interface" ]; then
        write_error "No Wi-Fi interface found. Please check your Wi-Fi adapter."
        exit 1
    fi
    echo "$interface"
}

# Function to get network list
get_network_list() {
    local wifi_interface=$1
    local networks_file="/tmp/networks_$$.txt"
    
    echo -e "${CYAN}Getting Wi-Fi networks list...${NC}"
    
    # Get list of preferred networks
    networksetup -listpreferredwirelessnetworks "$wifi_interface" > "$networks_file"
    
    # Process the list (skip the first line which is the header)
    if [ -s "$networks_file" ]; then
        tail -n +2 "$networks_file" | while read -r network; do
            echo "$network" | xargs
        done | sort -u
    fi
    
    rm -f "$networks_file"
}

# Function to save SSIDs to file
save_ssids_to_file() {
    local file="$1"
    shift
    local ssids=("$@")
    
    printf "%s\n" "${ssids[@]}" | sort -u > "$file"
    write_success "Successfully saved SSIDs to $file"
}

# Function to read SSIDs from file
read_ssids_from_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file" | grep -v '^[[:space:]]*$' || true
    fi
}

# Function to update hidden SSIDs list
update_hidden_ssids_list() {
    local hidden_file="$1"
    local allowed_file="$2"
    shift 2
    local new_ssids=("$@")
    
    # Read existing hidden SSIDs
    local existing_hidden=()
    while IFS= read -r line; do
        existing_hidden+=("$line")
    done < <(read_ssids_from_file "$hidden_file")
    
    # Read allowed SSIDs
    local allowed_ssids=()
    while IFS= read -r line; do
        allowed_ssids+=("$line")
    done < <(read_ssids_from_file "$allowed_file")
    
    # Combine existing and new SSIDs
    local all_ssids=("${existing_hidden[@]}" "${new_ssids[@]}")
    
    # Filter out allowed SSIDs and save
    local filtered_ssids=()
    for ssid in "${all_ssids[@]}"; do
        if [[ ! " ${allowed_ssids[@]} " =~ " ${ssid} " ]]; then
            filtered_ssids+=("$ssid")
        fi
    done
    
    save_ssids_to_file "$hidden_file" "${filtered_ssids[@]}"
    printf "%s\n" "${filtered_ssids[@]}"
}

# Function to configure network preferences
configure_network() {
    local interface="$1"
    shift
    local allowed_ssids=("$@")
    
    # First, remove any existing preferred networks
    networksetup -removeallpreferredwirelessnetworks "$interface" 2>/dev/null || true
    write_success "Removed all preferred networks"
    
    # Add allowed networks back
    for ssid in "${allowed_ssids[@]}"; do
        networksetup -addpreferredwirelessnetworkatindex "$interface" "$ssid" 0 OPEN
        write_success "Added $ssid to preferred networks"
    done
}

# Main execution begins here
echo -e "\n${CYAN}macOSWiFiFilter - Wi-Fi SSID Management Tool${NC}"
echo -e "${CYAN}======================================${NC}\n"

# Check system requirements
check_system_requirements

# Get script directory
script_dir=$(dirname "$0")
allowed_file="$script_dir/allowed_ssids.txt"
hidden_file="$script_dir/hidden_ssids.txt"

# Get Wi-Fi interface
wifi_interface=$(get_wifi_interface)
echo -e "Using Wi-Fi interface: ${CYAN}$wifi_interface${NC}"

# Get current network list
available_networks=()
while IFS= read -r network; do
    if [ ! -z "$network" ]; then
        available_networks+=("$network")
    fi
done < <(get_network_list "$wifi_interface")

if [ ${#available_networks[@]} -eq 0 ]; then
    write_warning "No networks found in preferred networks list."
    echo -e "\nPlease add networks in ${YELLOW}System Preferences > Network > Wi-Fi > Advanced${NC}"
    echo -e "Then run this script again to manage them."
    exit 1
fi

# Display available networks
echo -e "\n${CYAN}Available Networks:${NC}"
for network in "${available_networks[@]}"; do
    echo "  * $network"
done

# Read existing allowed SSIDs
existing_allowed_ssids=()
while IFS= read -r ssid; do
    if [ ! -z "$ssid" ]; then
        existing_allowed_ssids+=("$ssid")
    fi
done < <(read_ssids_from_file "$allowed_file")

# Process networks
if [ ${#existing_allowed_ssids[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Found existing allowed SSIDs:${NC}"
    for ssid in "${existing_allowed_ssids[@]}"; do
        echo "  * $ssid"
    done
    
    read -p $'\nWould you like to use these SSIDs? (y/n): ' response
    if [[ $response =~ ^[Yy]$ ]]; then
        allowed_ssids=("${existing_allowed_ssids[@]}")
        configure_network "$wifi_interface" "${allowed_ssids[@]}"
        echo -e "\n${GREEN}Applied ${#allowed_ssids[@]} existing allowed SSIDs${NC}"
    else
        allowed_ssids=()
    fi
else
    allowed_ssids=()
fi

# If not using existing allowed SSIDs, get user input
if [ ${#allowed_ssids[@]} -eq 0 ]; then
    echo -e "\n${CYAN}Enter SSIDs to allow (type 'done' when finished):${NC}"
    while true; do
        read -p "Enter SSID: " input
        if [ "$input" = "done" ]; then
            break
        fi
        if [[ " ${available_networks[@]} " =~ " ${input} " ]]; then
            allowed_ssids+=("$input")
            write_success "Added $input to allowed SSIDs"
        else
            write_warning "SSID '$input' is not in the list of networks."
            echo -e "Please add it in ${YELLOW}System Preferences > Network > Wi-Fi > Advanced${NC} first."
        fi
    done
    
    configure_network "$wifi_interface" "${allowed_ssids[@]}"
fi

# Save allowed SSIDs list
save_ssids_to_file "$allowed_file" "${allowed_ssids[@]}"

# Update hidden SSIDs list
hidden_ssids=()
while IFS= read -r ssid; do
    if [ ! -z "$ssid" ]; then
        hidden_ssids+=("$ssid")
    fi
done < <(update_hidden_ssids_list "$hidden_file" "$allowed_file" "${available_networks[@]}")

# Display summary
echo -e "\n${CYAN}Operation Summary:${NC}"
echo -e "${CYAN}----------------${NC}"
echo -e "${GREEN}Allowed SSIDs (${#allowed_ssids[@]}):${NC}"
for ssid in "${allowed_ssids[@]}"; do
    echo -e "${GREEN}  * $ssid${NC}"
done

echo -e "\n${YELLOW}Hidden SSIDs (${#hidden_ssids[@]}):${NC}"
for ssid in "${hidden_ssids[@]}"; do
    echo -e "${YELLOW}  * $ssid${NC}"
done

echo -e "\n${CYAN}File Locations:${NC}"
echo "  * Allowed SSIDs: $allowed_file"
echo "  * Hidden SSIDs: $hidden_file"

# Show final statistics
total_networks=${#available_networks[@]}
echo -e "\n${CYAN}Final Statistics:${NC}"
echo -e "${CYAN}================${NC}"
echo -e "Total Networks Found: ${YELLOW}$total_networks${NC}"
echo -e "Networks Hidden: ${RED}${#hidden_ssids[@]}${NC}"
echo -e "Networks Visible: ${GREEN}${#allowed_ssids[@]}${NC}"

write_success "\nmacOSWiFiFilter completed successfully!"
