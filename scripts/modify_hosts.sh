#!/bin/bash

# Function to add a line to /etc/hosts if it doesn't already exist
add_host_entry() {
    local ip=$1
    local hostname=$2

    # Check if the entry already exists
    if ! grep -q "$ip $hostname" /etc/hosts; then
        echo "$ip $hostname" | sudo tee -a /etc/hosts > /dev/null
        echo "Added $ip $hostname to /etc/hosts"
    else
        echo "Entry $ip $hostname already exists in /etc/hosts"
    fi
}

# Function to remove a line from /etc/hosts
remove_host_entry() {
    local hostname=$1

    # Remove the line containing the hostname
    sudo sed -i '' "/$hostname/d" /etc/hosts
    echo "Removed $hostname from /etc/hosts"
}

# Usage: modify_hosts.sh add 127.0.0.1 mydomain.local
#        modify_hosts.sh remove mydomain.local
if [ "$1" == "add" ]; then
    add_host_entry "$2" "$3"
elif [ "$1" == "remove" ]; then
    remove_host_entry "$2"
else
    echo "Usage: $0 {add|remove} [IP] [hostname]"
    exit 1
fi