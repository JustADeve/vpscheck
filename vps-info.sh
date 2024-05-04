#!/bin/bash

# Get CPU usage
avg_cpu_today=$(top -bn1 | awk '/^%Cpu/{print 100-$8}')

# Get memory usage
mem_total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
mem_used=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
mem_usage=$(echo "scale=2; (($mem_total - $mem_used) / $mem_total) * 100" | bc -l)

# Get disk usage
disk_total=$(df -h --output=size / | sed 1d)
disk_used=$(df -h --output=used / | sed 1d | tr -d " ")
disk_usage=$(echo "scale=2; ($disk_used / $disk_total) * 100" | bc -l)

# Get network usage
rx_speed=$(cat /sys/class/net/eth0/statistics/rx_bytes)
tx_speed=$(cat /sys/class/net/eth0/statistics/tx_bytes)
sleep 1
rx_speed_new=$(cat /sys/class/net/eth0/statistics/rx_bytes)
tx_speed_new=$(cat /sys/class/net/eth0/statistics/tx_bytes)
rx_speed=$(( ($rx_speed_new - $rx_speed) / 1024 ))
tx_speed=$(( ($tx_speed_new - $tx_speed) / 1024 ))

# Get uptime
uptime=$(uptime -p)

# Get system information
system_info=$(uname -a)

# Print the collected information
echo "VPS Information:"
echo "--------------"
echo "Average CPU Usage Today: ${avg_cpu_today}%"
echo "Memory Usage: ${mem_usage}% (${mem_used} kB / ${mem_total} kB)"
echo "Disk Usage: ${disk_usage}% (${disk_used} used out of ${disk_total})"
echo "Network Usage (RX): ${rx_speed} KB/s"
echo "Network Usage (TX): ${tx_speed} KB/s"
echo "Uptime: ${uptime}"
echo "System Info: ${system_info}"
echo "Running Services:"
service --status-all
