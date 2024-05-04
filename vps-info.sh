#!/bin/bash

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Get memory usage
mem_total=$(free -m | awk 'NR==2{print $2}')
mem_used=$(free -m | awk 'NR==2{print $3}')
mem_usage=$(echo "scale=2; $mem_used / $mem_total * 100" | bc -l)

# Get disk usage
disk_total=$(df -h | grep '/dev/vda1' | awk '{print $2}')
disk_used=$(df -h | grep '/dev/vda1' | awk '{print $3}')
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

# Get running services
services=$(service --status-all)

# Print the collected information
echo "VPS Information:"
echo "--------------"
echo "CPU Usage: $cpu_usage %"
echo "Memory Usage: $mem_usage % ($mem_used MB / $mem_total MB)"
echo "Disk Usage: $disk_usage % ($disk_used used out of $disk_total)"
echo "Network Usage (RX): $rx_speed KB/s"
echo "Network Usage (TX): $tx_speed KB/s"
echo "Uptime: $uptime"
echo "System Info: $system_info"
echo "Running Services:"
echo "$services"
