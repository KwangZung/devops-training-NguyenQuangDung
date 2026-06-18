#!/bin/bash
echo "1. Spawn 1 process sleep 300 background."
sleep 300 &
# Toán tử & khiến cho tiến trình chạy ngầm

SLEEP_PID=$! 
# $!: biến chứa PID của tiến trình ngầm gần nhất
MY_PPID=$$
# $$: biến chứa PID của script hiện tại là tiến trình cha của sleep 300

echo "2. Hiển thị PPID/PID của nó."
echo "    - Tiến trình cha: tiến trình của lệnh bash lab-process.sh (PPID): $MY_PPID"
echo "    - Tiến trình con: tiến trình của lệnh sleep 300 (PID): $SLEEP_PID"

echo "3. Gửi SIGTERM, kiểm tra exit code."
kill -15 $SLEEP_PID
wait $SLEEP_PID
EXIT_CODE=$?
#$?: biến chứa exit code của tiến trình vừa thực thi

echo "    - Exit code của tiến trình sleep: $EXIT_CODE"

if [ $EXIT_CODE -eq 143 ]; then
    echo "    - Tiến trình đã bị ngắt thành công bởi SIGTERM"
elif [ $EXIT_CODE -eq 137 ]; then
    echo "    - Tiến trình đã bị ngắt bởi SIGKILL"
elif [ $EXIT_CODE -eq 129 ]; then
    echo "    - Tiến trình đã bị ngắt bởi SIGHUP"
elif [ $EXIT_CODE -eq 128 ]; then
    echo "    - Tiến trình đã bị ngắt bởi SIGINT"
else
    echo "    - Tiến trình bị ngắt bởi lệnh khác"
fi
