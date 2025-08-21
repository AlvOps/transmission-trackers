#!/bin/bash

# Function to display error messages and exit
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Function to validate transmission connection
validate_transmission() {
    echo "Testing Transmission connection..."
    if ! transmission-remote -n "$USERNAME:$PASSWORD" -l >/dev/null 2>&1; then
        error_exit "Cannot connect to Transmission. Check credentials or ensure Transmission is running."
    fi
}

# Function to validate torrent ID exists
validate_torrent_id() {
    local torrent_id=$1
    if ! transmission-remote -n "$USERNAME:$PASSWORD" -l | awk '{print $1}' | grep -q "^$torrent_id$"; then
        error_exit "Torrent ID $torrent_id not found in the list."
    fi
}

# Get credentials securely
read -p "Enter Transmission username: " USERNAME
read -s -p "Enter Transmission password: " PASSWORD
echo ""

# Validate credentials
validate_transmission

# Get a list of torrents with proper formatting
echo "Fetching list of torrents..."
echo "=========================================================="
transmission-remote -n "$USERNAME:$PASSWORD" -l | head -n 1
transmission-remote -n "$USERNAME:$PASSWORD" -l | tail -n +2 | sed '$d'
echo "=========================================================="

# Prompt user for the torrent ID with validation
while true; do
    read -p "Enter the torrent ID to add trackers: " TORRENT_ID
    
    # Validate input is a number
    if ! [[ "$TORRENT_ID" =~ ^[0-9]+$ ]]; then
        echo "❌ Please enter a valid numeric torrent ID."
        continue
    fi
    
    # Validate torrent ID exists
    if validate_torrent_id "$TORRENT_ID"; then
        break
    else
        echo "❌ Torrent ID $TORRENT_ID not found. Please try again."
    fi
done

echo "Adding trackers to torrent ID: $TORRENT_ID ..."

# Track success/failure counters
SUCCESS_COUNT=0
FAIL_COUNT=0

# Fetch tracker list and process
TRACKER_URL="https://ngosang.github.io/trackerslist/trackers_best.txt"
echo "Fetching trackers from $TRACKER_URL..."

if ! curl -s --fail "$TRACKER_URL" > /tmp/trackers.txt 2>&1; then
    error_exit "Failed to download tracker list. Check internet connection."
fi

if [[ ! -s /tmp/trackers.txt ]]; then
    error_exit "Downloaded tracker list is empty."
fi

# Process trackers
while read -r tracker; do
    # Skip empty lines
    [[ -z "$tracker" ]] && continue
    
    # Validate tracker URL format
    if [[ $tracker =~ ^(http|udp|https):// ]]; then
        echo "Adding tracker: $(echo "$tracker" | cut -c1-50)..."
        if transmission-remote -n "$USERNAME:$PASSWORD" -t "$TORRENT_ID" --tracker-add "$tracker" >/dev/null 2>&1; then
            ((SUCCESS_COUNT++))
        else
            echo "   ❌ Failed to add: $(echo "$tracker" | cut -c1-50)..."
            ((FAIL_COUNT++))
        fi
    else
        echo "Skipping invalid tracker: $(echo "$tracker" | cut -c1-50)..."
        ((FAIL_COUNT++))
    fi
done < <(grep -v '^$' /tmp/trackers.txt)

# Cleanup
rm -f /tmp/trackers.txt

echo "=========================================================="
echo "✅ Trackers added successfully!"
echo "   Successful: $SUCCESS_COUNT"
echo "   Failed: $FAIL_COUNT"
echo "   Total processed: $((SUCCESS_COUNT + FAIL_COUNT))"
echo "=========================================================="
