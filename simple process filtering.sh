#!/bin/bash

search_process() {
    echo "Choose search method: (1) By Process Name (COMMAND), (2) By Part of Process Name, (3) By Process ID (PID)"
    read search_method

    if [ "$search_method" -eq 1 ]; then
        echo "Enter the full name of the process:"
        read fullname
        list_of_process=$(ps -eo pid,comm | grep -w "$fullname" | awk '{print $1, $2}')
    elif [ "$search_method" -eq 2 ]; then
        echo "Enter part of the name of the process:"
        read partname
        list_of_process=$(ps -eo pid,comm | grep "$partname" | awk '{print $1, $2}')
    elif [ "$search_method" -eq 3 ]; then
        echo "Enter the PID of the process:"
        read pid
        list_of_process=$(ps -eo pid,comm | grep -w "$pid" | awk '{print $1, $2}')
    else
        echo "Invalid option. Please select 1, 2, or 3."
        return 1
    fi

    if [ "$list_of_process" ]; then
        echo "Process found:"
        echo "$list_of_process"
        echo "Do you wish to kill the process? y/n:"
        read answer
        lower_case=${answer,,}
        if [ "$lower_case" = "y" ]; then
            pid_to_kill=$(echo "$list_of_process" | awk '{print $1}')
            kill -9 "$pid_to_kill"
            echo "Process with PID $pid_to_kill has been killed."
        else
            echo "Process not killed."
        fi
    else
        echo "Process not found!"
    fi
}

filter_processes_by_mem() {
    echo "Enter the minimum MEM usage (in percentage):"
    read mem_limit

    filtered_processes=$(ps -eo pid,comm,%mem --sort=-%mem | awk -v limit="$mem_limit" '$3 >= limit {print $2 "," $1 "," $3}')

    if [ "$filtered_processes" ]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        output_file="FilteredProcessList_$timestamp.csv"
        echo "COMMAND,PID,MEM" > "$output_file"
        echo "$filtered_processes" >> "$output_file"
        chmod 644 "$output_file"
        echo "Filtered processes saved to $output_file."

        files_count=$(ls FilteredProcessList_*.csv | wc -l)
        if [ "$files_count" -gt 5 ]; then
            oldest_files=$(ls -t FilteredProcessList_*.csv | tail -n +6)
            echo "Removing old files:"
            echo "$oldest_files"
            rm $oldest_files
        fi
    else
        echo "No processes found with MEM usage greater than or equal to $mem_limit%."
    fi
}

echo "Choose an option:"
echo "1) Search and kill a process"
echo "2) Filter processes by MEM usage"
read option

if [ "$option" -eq 1 ]; then
    search_process
elif [ "$option" -eq 2 ]; then
    filter_processes_by_mem
else
    echo "Invalid option. Please choose 1 or 2."
fi
