#!/bin/bash
#Author: Alif Sihat
# Function to log the usage information
log_usage() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local service=$1
    local path=$2
    local cpu_usage=$3
    local ram_usage=$4

    echo "$timestamp - Service: $service, Path: $path, CPU Usage: $cpu_usage%, RAM Usage: $ram_usage%" >> cpu-monitor.log
}

# Function to check and overwrite the log file after 1 days
overwrite_log_file() {
    local log_file="system-monitor.log"
    local threshold_days=1

    if [ -f "$log_file" ]; then
        local last_modified=$(stat -c %Y "$log_file")
        local current_time=$(date +%s)
        local age=$(( (current_time - last_modified) / 86400 )) # Calculate age in days

        if [ $age -ge $threshold_days ]; then
            mv "$log_file" "${log_file}.old"
            echo "Log file overwritten at $(date +"%Y-%m-%d %H:%M:%S")" > "$log_file"
        fi
    fi
}

# Main loop to monitor usage
while true; do
    # Get the current timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Get the top process based on CPU usage 
    top_process=$(ps -eo pid,%cpu,%mem,cmd --sort=-%cpu | sed -n '2p')

    # Extract relevant information
    pid=$(echo $top_process | awk '{print $1}')
    cpu_usage=$(echo $top_process | awk '{print $2}')
    ram_usage=$(echo $top_process | awk '{print $3}')
    command=$(echo $top_process | awk '{$1=$2=$3=""; print $0}' | xargs)

    # Get the service and path of the process 
    path=$(readlink -f /proc/$pid/exe)
    service=$(basename $path)

    # Log the usage information
    log_usage "$service" "$path" "$cpu_usage" "$ram_usage"

    # Sleep for 5 seconds before checking again
    sleep 5
done
