#!/usr/bin/env bash

echo "--- Part B: Pipe & redirect ---"

echo "1. Liệt kê 5 process tốn RAM nhất, cột PID + COMMAND + %MEM."
ps -eo pid,command,%mem --sort=-%mem | head -6


echo -e "\n2. Đếm số file .log trong /var/log (không đi sâu hơn 2 cấp)."
find /var/log -maxdepth 2 -name "*.log" | wc -l

echo -e "\n3.  Tìm 10 IP xuất hiện nhiều nhất trong /var/log/auth.log (nếu có)."
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" /var/log/auth.log | sort | uniq -c | sort -nr | head -10

echo -e "\n4. Lấy hostname + kernel version + uptime, ghi vào system-info.txt theo format:"
echo "host=$(hostname)" > system-info.txt
echo "kernel=$(uname -r)" >> system-info.txt
echo "uptime=$(uptime -p)" >> system-info.txt
echo -e "\nNội dung file system-info.txt:\n"
cat system-info.txt