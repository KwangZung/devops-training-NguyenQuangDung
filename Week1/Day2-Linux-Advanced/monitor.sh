#!/usr/bin/env bash

LOG_FILE="$HOME/monitor.log"

CPU_HIGH_COUNT=0

trap 'echo -e "\n[!] Nhận được tín hiệu ngắt (SIGINT/SIGTERM). Đang tiến hành dọn dẹp và dừng giám sát một cách an toàn (Graceful Exit)..."; exit 0' SIGINT SIGTERM

echo "Bắt đầu giám sát tài nguyên mỗi 10s. Nhấn Ctrl+C để dừng."

while true; do
    CPU_IDLE=$(LC_ALL=C top -bn1 | grep "Cpu(s)" | tr ',' ' ' | awk '{for(i=1;i<=NF;i++) if($i=="id") print $(i-1)}' | awk -F. '{print $1}')
    if [ -z "$CPU_IDLE" ]; then CPU_IDLE=100; fi
    CPU_USAGE=$((100 - CPU_IDLE))

    MEM_USAGE=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')

    TOP_PROCS=$(ps -eo pid,user,%cpu,comm --sort=-%cpu | head -n 4 | awk 'NR>1 {print "   -> PID: "$1" | User: "$2" | CPU: "$3"% | Lệnh: "$4}')

    echo "========================================="
    echo "Thời gian: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "CPU: ${CPU_USAGE}%"
    echo "RAM: ${MEM_USAGE}%"
    echo "Top 3 Process ngốn CPU:"
    echo "$TOP_PROCS"
    echo "========================================="

    if [ "$CPU_USAGE" -gt 80 ]; then
        ((CPU_HIGH_COUNT++))
    else
        CPU_HIGH_COUNT=0
    fi

    if [ "$CPU_HIGH_COUNT" -ge 3 ]; then
        WARNING_MSG="[WARNING] $(date '+%Y-%m-%d %H:%M:%S') - CẢNH BÁO: CPU vượt 80% trong 3 chu kỳ liên tiếp (Hiện tại: ${CPU_USAGE}%)"
        echo "$WARNING_MSG" >> "$LOG_FILE"
        echo "$WARNING_MSG"
        
        CPU_HIGH_COUNT=0
    fi

    sleep 10
done
