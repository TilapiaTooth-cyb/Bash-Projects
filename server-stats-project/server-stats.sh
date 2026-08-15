#!/bin/bash
: 'This is a really simple script to display system information from a linux device. 
I tried to keep it free from many dependencies or third party tools to ensure compatibility across different linux distros and devices.'
echo "
###########################
    System Information"

cpu_usage() {
	read -r cpu user nice system idle iowait irq softirq steal guest < /proc/stat
	total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
	idle1=$idle
	sleep 1
	read -r cpu user nice system idle iowait irq softirq steal guest < /proc/stat
	total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
	idle2=$idle
	total_diff=$((total2 - total1))
	idle_diff=$((idle2 - idle1))
	usage=$((100 * (total_diff - idle_diff) / total_diff))
	echo "###########################
CPU Usage: ${usage}%"
}

memory_usage(){
	echo "###########################"
	free -m | awk '/^Mem:/ {printf "Memory Usage: %sMB / %sMB (%.1f%%)\n", $3, $2, ($3/$2)*100}'
}

disk_usage() {
    echo "###########################"
    df -h --output=target,size,used,avail,pcent -x tmpfs -x devtmpfs -x squashfs | tail -n +2 | while read -r mount size used avail pcent; do
	echo "Mount: ${mount} | Used: ${used} / ${size} (${pcent})"
    done
}

top_cpu() {
echo "###########################
Process with most CPU usage (top 5):"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
}

top_mem() {
echo "###########################
Process by MEMORY usage (top 5):"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6
}

cpu_usage
memory_usage
disk_usage
top_cpu
top_mem

