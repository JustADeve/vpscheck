#!/bin/bash

# Function to install necessary packages if not found
install_packages() {
    echo "Installing necessary packages..."
    if [ -x "$(command -v apt)" ]; then
        apt update
        apt install -y net-tools
    elif [ -x "$(command -v yum)" ]; then
        yum install -y net-tools
    else
        echo "Error: Unable to install necessary packages. Please install them manually and try again."
        exit 1
    fi
}

# Check if net-tools is installed, install if not
if ! command -v netstat &> /dev/null; then
    install_packages
fi

# Check again if net-tools is installed
if ! command -v netstat &> /dev/null; then
    echo "Error: net-tools is not installed. Please install it and try again."
    exit 1
fi

# Initialize variables for max CPU usage and network usage
max_cpu_usage=0
rx_speed=0
tx_speed=0

# Get CPU usage and track maximum CPU usage
while IFS=" " read -r cpu_user cpu_nice cpu_sys cpu_idle cpu_wait cpu_irq cpu_sr cpu_steal cpu_guest cpu_guest_nice; do
    cpu_usage=$((100 - cpu_idle))
    if (( cpu_usage > max_cpu_usage )); then
        max_cpu_usage=$cpu_usage
    fi
done < <(top -bn1 | awk '/^%Cpu/{print $2, $4, $6, $8, $10, $12, $14, $16, $18, $20}')

# Get memory usage
mem_total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
mem_free=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
mem_used=$((mem_total - mem_free))
mem_usage=$(echo "scale=2; $mem_used / $mem_total * 100" | bc -l)

# Get disk usage
disk_usage=$(df -h --output=pcent / | sed 1d | tr -d ' %')

# Get network usage
network_stats=$(netstat -i | awk 'NR>2 {rx+=$3; tx+=$7} END{print rx/1024, tx/1024}')
rx_speed=$(echo "$network_stats" | awk '{print int($1)}')
tx_speed=$(echo "$network_stats" | awk '{print int($2)}')

# Get uptime
uptime=$(uptime -p)

# Get system information
system_info=$(uname -a)

# Print the collected information
echo "VPS Information:"
echo "--------------"
echo "Maximum CPU Usage Today: ${max_cpu_usage}%"
echo "Memory Usage: ${mem_usage}% (${mem_used} kB used / ${mem_total} kB total)"
echo "Disk Usage: ${disk_usage}%"
echo "Network Usage (RX): ${rx_speed} KB/s"
echo "Network Usage (TX): ${tx_speed} KB/s"
echo "Uptime: ${uptime}"
echo "System Info: ${system_info}"
echo "Running Services:"
service --status-all
