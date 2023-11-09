#!/bin/bash

echo '
 /$$   /$$                 /$$                  /$$$$$$                        /$$                         /$$ /$$                    
| $$$ | $$                | $$                 /$$__  $$                      | $$                        | $$| $$                    
| $$$$| $$  /$$$$$$   /$$$$$$$  /$$$$$$       | $$  \__/  /$$$$$$  /$$$$$$$  /$$$$$$    /$$$$$$   /$$$$$$ | $$| $$  /$$$$$$   /$$$$$$ 
| $$ $$ $$ /$$__  $$ /$$__  $$ /$$__  $$      | $$       /$$__  $$| $$__  $$|_  $$_/   /$$__  $$ /$$__  $$| $$| $$ /$$__  $$ /$$__  $$
| $$  $$$$| $$  \ $$| $$  | $$| $$$$$$$$      | $$      | $$  \ $$| $$  \ $$  | $$    | $$  \__/| $$  \ $$| $$| $$| $$$$$$$$| $$  \__/
| $$\  $$$| $$  | $$| $$  | $$| $$_____/      | $$    $$| $$  | $$| $$  | $$  | $$ /$$| $$      | $$  | $$| $$| $$| $$_____/| $$      
| $$ \  $$|  $$$$$$/|  $$$$$$$|  $$$$$$$      |  $$$$$$/|  $$$$$$/| $$  | $$  |  $$$$/| $$      |  $$$$$$/| $$| $$|  $$$$$$$| $$      
|__/  \__/ \______/  \_______/ \_______/       \______/  \______/ |__/  |__/   \___/  |__/       \______/ |__/|__/ \_______/|__/  '



cd "$(dirname "$0")"

# Define the keys for each node
declare -A node_key
node_key=(
        ["1"]="1KhSvi6DTg7JNuTTQs74BMzRwmDQAgi9xPYdgdsffTzSaMkerayA5b3yomGfMk3AF5hhhhhhhGFwtb64tZUpQNpewvJjrYMfPYx1hntQCkF7TZtG5aveoiYCMK3kNRkwimMr2pAgEHEoy1YRo7Gq8fnFPW3Hr1Awfb1L9zSeHLYVjUdWUGZ41"
        ["2"]="1RwRJXYMZyAMYJxg6MomqX8gZeAjGGqvEwydXQsTkPPzC3KP3DYmutX5fA8JgPRfhRiezDhhhhhhh4AwApHJhAvjkZBbnr1u2pUzHBuaSLgADziCcacVM39nVQ6HSDjARYDQCvbR4FDueuscCUoUCDS6BtBZWZ75eFTBpSSjEFN7YfZySshih"
        ["3"]="1KMB7GBc4Lh3kQ7WoVaLrYmFcRwDYJVTf7MkDsp6HdfroAG7EPNvmRi8jdkp3oyLx3ioyMhhhhhhhhhhvAKZnakGrX6p7gfFG2nBgghPbA9QdSVNuU1AoPdqvsEG9fbxJjRyQ9XbAnhwa1jGCaZtEXRYropFpBtah6u4RK6cYxT2jKKC53s3P"
        # Add as many nodes as you want to automate...
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
    response=$(curl -s --fail --max-time 10 "$base_url" -H 'accept: application/json' -H 'content-type: application/json' --data "{\"mpk\":\"$key\"}")

    if [ $? -ne 0 ]; then
        echo "Error: API request failed for node $node_name with key $key"
        continue
    fi

    if ! echo "$response" | jq -e . > /dev/null 2>&1; then
        echo "Error: Invalid JSON response for node $node_name with key $key"
        continue
    fi

    current_container_status=$(container_status "${container_name}${node_name}")

    epoch=$(echo "$response" | jq -r '.[].NextEventMsg' | cut -d' ' -f1)

    if [ "$epoch" -gt 11 ] && [ "$current_container_status" == "running" ]; then
        echo -n "Stopping container ${container_name}${node_name} due to epoch $epoch..."
        sudo docker stop "${container_name}${node_name}"
    elif [ "$epoch" -lt 10 ] && [ "$current_container_status" != "running" ]; then
        echo -n "Starting container ${container_name}${node_name} due to epoch $epoch..."
        sudo docker start "${container_name}${node_name}"
    fi
done

sleep 2
