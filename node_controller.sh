#!/bin/bash

### Colors ###
ESC=$(printf '\033')
RESET="${ESC}[0m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
CYAN="${ESC}[36m"

### Color Functions ###
colorprint() {
  local color=$1
  shift
  printf "${!color}%s${RESET}\n" "$*"
}

echo '
 /$$   /$$                 /$$                  /$$$$$$                        /$$                         /$$ /$$                    
| $$$ | $$                | $$                 /$$__  $$                      | $$                        | $$| $$                    
| $$$$| $$  /$$$$$$   /$$$$$$$  /$$$$$$       | $$  \__/  /$$$$$$  /$$$$$$$  /$$$$$$    /$$$$$$   /$$$$$$ | $$| $$  /$$$$$$   /$$$$$$ 
| $$ $$ $$ /$$__  $$ /$$__  $$ /$$__  $$      | $$       /$$__  $$| $$__  $$|_  $$_/   /$$__  $$ /$$__  $$| $$| $$ /$$__  $$ /$$__  $$
| $$  $$$$| $$  \ $$| $$  | $$| $$$$$$$$      | $$      | $$  \ $$| $$  \ $$  | $$    | $$  \__/| $$  \ $$| $$| $$| $$$$$$$$| $$  \__/
| $$\  $$$| $$  | $$| $$  | $$| $$_____/      | $$    $$| $$  | $$| $$  | $$  | $$ /$$| $$      | $$  | $$| $$| $$| $$_____/| $$      
| $$ \  $$|  $$$$$$/|  $$$$$$$|  $$$$$$$      |  $$$$$$/|  $$$$$$/| $$  | $$  |  $$$$/| $$      |  $$$$$$/| $$| $$|  $$$$$$$| $$      
|__/  \__/ \______/  \_______/ \_______/       \______/  \______/ |__/  |__/   \___/  |__/       \______/ |__/|__/ \_______/|__/  

								      version 1.1
																												
CHANGE LOG:
v1.1 - 
- Increased readability of output with color and region defined areas.
- Added verbose output for better debugging.

v1.0 -
- Inital release with working auto start and stop functionality.
- User adjustable variables to start containers under 10 epochs and stop after 11.
'																												
echo "**********************************************************************************************************************************"
echo ""
echo ""

wait 2

cd "$(dirname "$0")"

# Define the keys for each node, one per line. Use # to skip checking specific nodes.

declare -A node_key
node_key=(
        #["1"]="1KhSvi6DTg7JNuTTQs74BMzRYdgdsffTzSaMkerayA5b3yomGfMk3AF5GFwtb6DUofeP64tZUpQNpewvJjrYMfPYx1hntQCkF7TZtG5aveoiYCMK3kNRkwimMr2pAgEHEoy1YRo7Gq8fnFPW3Hr1Awfb1L9zSeHLYVjUdWUGZ41"
        ["2"]="1RwRJXYMZyAMYJxg6MomqX8gZdXQsTkPPzC3KP3DYmutX5fA8JgPRfhRiezD4TQqSwAwABFpHJhAvjkZBbnr1u2pUzHBuaSLgADziCcacVM39nVQ6HSDjARYDQCvbR4FDueuscCUoUCDS6BtBZWZ75eFTBpSSjEFN7YfZySshih"
        ["3"]="1KMB7GBc4Lh3kQ7WoVaLrYmFcMkDsp6HdfroAG7EPNvmRi8jdkp3oyLx3tRVuGXmbnQioyMvAKZnakGrX6p7gfFG2nBgghPbA9QdSVNuU1AoPdqvsEG9fbxJjRyQ9XbAnhwa1jGCaZtEXRYropFpBtah6u4RK6cYxT2jKKC53s3P"
        ["4"]=""
        ...
)

base_url="https://monitor.incognito.org/pubkeystat/stat"
container_name="inc_mainnet_"

# Function to check Docker container status
container_status() {
    local container="$1"
    status=$(docker inspect --format='{{.State.Status}}' "$container")
    echo "$status"
}

for node_name in "${!node_key[@]}"; do
    key="${node_key[$node_name]}"
	colorprint CYAN "+==========================================+"
    echo "Checking status for node $node_name with key $key..."

    response=$(curl -s --fail --max-time 10 "$base_url" -H 'accept: application/json' -H 'content-type: application/json' --data "{\"mpk\":\"$key\"}")

    if [ $? -ne 0 ]; then
        colorprint RED "Error: API request failed for node $node_name with key $key"
        continue
    fi

    if ! echo "$response" | jq -e . > /dev/null 2>&1; then
        colorprint RED "Error: Invalid JSON response for node $node_name with key $key"
        continue
    fi
	echo "--------------------------------------------"

    echo "API Response for node $node_name: $response"
	echo "--------------------------------------------"

    current_container_status=$(container_status "${container_name}${node_name}")
    echo "Current container status for node $node_name: $current_container_status"
	echo "--------------------------------------------"

    epoch=$(echo "$response" | jq -r '.[].NextEventMsg' | cut -d' ' -f1)
    echo "Epoch for node $node_name: $epoch"
	echo "--------------------------------------------"

    if ! [[ "$epoch" =~ ^[0-9]+$ ]]; then
        colorprint RED "Warning: Invalid epoch for node $node_name with key $key"
        continue
    fi

    if [ "$epoch" -gt 11 ] && [ "$current_container_status" == "running" ]; then
        colorprint YELLOW "Stopping container ${container_name}${node_name} due to epoch $epoch..."
        sudo docker stop "${container_name}${node_name}"
    elif [ "$epoch" -lt 10 ] && [ "$current_container_status" != "running" ]; then
        colorprint GREEN "Starting container ${container_name}${node_name} due to epoch $epoch..."
        sudo docker start "${container_name}${node_name}"
    fi
	colorprint CYAN "+==========================================+"
	echo ""
	echo ""
done

sleep 2
