#!/bin/bash

# Function to install necessary packages if not found
install_packages() {
    echo "Installing necessary packages..."
    if [ -x "$(command -v apt)" ]; then
        apt update
        apt install -y bc sysstat
    elif [ -x "$(command -v yum)" ]; then
        yum install -y bc sysstat
    else
        echo "Error: Unable to install necessary packages. Please install them manually and try again."
        exit 1
    fi
}

# Check if required packages are installed
if ! command -v bc &> /dev/null || ! command -v sar &> /dev/null; then
    install_packages
fi

# Check again if required packages are installed
if ! command -v bc &> /dev/null || ! command -v sar &> /dev/null; then
    echo "Error: Required packages are not installed. Please install them and try again."
    exit 1
fi

# Get CPU usage
avg_cpu_today=$(sar -u | awk 'NR > 3 { sum += $8 } END { if (NR > 0) printf "%.2f", sum / NR else print "0" }')

# Get memory usage
mem_total=$(free -m | awk 'NR==2{print $2}')
mem_used=$(free -m | awk 'NR==2{print $3}')
mem_usage=$(echo "scale=2; $mem_used / $mem_total * 100" | bc -l)

# Get disk usage
disk_info=$(df -h | grep '/dev/vda1')
disk_total=$(echo "$disk_info" | awk '{print $2}')
disk_used=$(echo "$disk_info" | awk '{print $3}')
disk_usage=$(echo "scale=2; $disk_used / $disk_total * 100" | bc -l)

# Get network usage
rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes)
tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes)
sleep 1
rx_bytes_new=$(cat /sys/class/net/eth0/statistics/rx_bytes)
tx_bytes_new=$(cat /sys/class/net/eth0/statistics/tx_bytes)
rx_speed=$(( ($rx_bytes_new - $rx_bytes) / 1024 ))
tx_speed=$(( ($tx_bytes_new - $tx_bytes) / 1024 ))

# Get uptime
uptime=$(uptime -p)

# Get system information
system_info=$(uname -a)

# Print the collected information
echo "VPS Information:"
echo "--------------"
echo "Average CPU Usage Today: ${avg_cpu_today}%"
echo "Memory Usage: ${mem_usage}% (${mem_used} MB / ${mem_total} MB)"
echo "Disk Usage: ${disk_usage}% (${disk_used} used out of ${disk_total})"
echo "Network Usage (RX): ${rx_speed} KB/s"
echo "Network Usage (TX): ${tx_speed} KB/s"
echo "Uptime: ${uptime}"
echo "System Info: ${system_info}"
echo "Running Services:"
service --status-all
