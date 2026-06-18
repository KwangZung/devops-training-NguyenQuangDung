# Task Submission: Day 2 - Linux Advanced

## Task: `Linux Advanced (Process, systemd, Permission, Networking)`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 1 / Week 1 / Day 2`
- **Branch**: `phase-1/week-1/day-2-linux-advanced`
- **Submitted at**: `2026-06-18`
- **Time spent**: `Đang thực hiện...`

## 1. Mục tiêu
- **Part A:** Nắm vững lý thuyết về Process & Signal (`SIGTERM`, `SIGKILL`, Zombie Process...). Chạy ngầm tiến trình, bắt PID và điều khiển bằng signal.
- **Part B:** Đã tạo file systemd unit (`webapp.service`) để daemonize Python HTTP Server và cấu hình tự động hồi sinh.
- **Part C:** (Chưa làm) - Quản lý permission nâng cao (setgid, setfacl).
- **Part D:** (Chưa làm) - Viết script giám sát tài nguyên (CPU/MEM) qua systemd.

## 2. Cách chạy
**(Part A: Process & Signal)**
Cấp quyền thực thi và chạy script thực hành:
```bash
chmod +x lab-process.sh
./lab-process.sh
```

**(Part B: Systemd Webapp)**
Copy file service vào hệ thống và kích hoạt:
```bash
sudo mkdir -p /opt/webapp
echo "<h1>Hello JITS</h1>" | sudo tee /opt/webapp/index.html
sudo cp webapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now webapp
```

## 3. Kết quả
### Part A: Process & Signal
- Đã hoàn thành trả lời 5 câu hỏi lý thuyết tại file: [`notes.md`](./notes.md) (Có chèn ảnh minh họa cấu trúc lệnh `ps auxf` và cấu trúc Zombie process).
- Đã hoàn thành file thực hành [`lab-process.sh`](./lab-process.sh):
  - Chạy `sleep 300` dưới nền (background).
  - Xuất ra PID và PPID chuẩn xác.
  - Gửi thành công tín hiệu `SIGTERM` (15) để ngắt chương trình và xác nhận Exit Code là `143`.
  - Có demo bổ sung lệnh `nohup` và cách dùng `pkill -f`.

**Ảnh minh chứng kết quả chạy script `lab-process.sh`:**
![Kết quả thực hành Part A](screenshots/lab_process_result.jpg)

### Part B: Systemd Service
- Đã tạo thành công file [`webapp.service`](./webapp.service) phục vụ chạy ngầm web server bằng lệnh `python3 -m http.server`.
- Cấu hình thành công tính năng auto restart)dưới 5 giây thông qua cờ `Restart=on-failure` và `RestartSec=3`.
- Đã test diệt tiến trình bằng cờ `-9` và kiểm chứng qua logs bằng lệnh `journalctl -u webapp -f` thấy systemd tự động khởi tạo lại tiến trình với PID mới.

**Ảnh minh chứng kết quả chạy và hồi sinh `webapp.service`:**
![Kết quả thực hành Part B](screenshots/part-b-result.jpg)

## 4. Khó khăn & cách giải quyết
- **Vấn đề:** Dễ nhầm lẫn giữa chức năng của `nohup`, `&`, `disown` và `setsid` khi muốn giữ tiến trình chạy ngầm.
  - **Cách giải quyết:** Nghiên cứu kỹ và phân tách rạch ròi 2 khái niệm: miễn nhiễm với tín hiệu `SIGHUP` khi tắt terminal và chạy trong background để trả lại quyền gõ lệnh cho terminal. Đã note chi tiết vào `notes.md`.
- **Vấn đề:** Không hiểu tại sao tiến trình chết vì signal lại sinh ra exit code `143`.
  - **Cách giải quyết:** Tìm hiểu về quy ước exit code của bash shell đối với các tiến trình bị ngắt bằng tín hiệu (128 + mã signal). Với `SIGTERM` có signal 15, kết quả là 128 + 15 = 143.
- **Vấn đề (Part B):** Dùng lệnh `kill <PID>` thông thường để test Auto Restart của systemd nhưng service không chịu khởi động lại mà báo "Deactivated successfully".
  - **Cách giải quyết:** Đã phát hiện ra `kill` không cờ mặc định gửi tín hiệu `SIGTERM`. Systemd coi `SIGTERM` là thao tác tắt an toàn hợp lệ (như `systemctl stop`), nên cờ `Restart=on-failure` bị vô hiệu hóa. Phải dùng `kill -9 <PID>` (gửi tín hiệu `SIGKILL`) để ép ứng dụng chết phi lý (crashes), lúc này systemd mới chịu kích hoạt cơ chế hồi sinh.

## 5. Reference
- [systemd for Administrators (Lennart Poettering)](https://0pointer.de/blog/projects/systemd-for-admins-1.html)
- [Linux permissions deep dive](https://www.redhat.com/sysadmin/linux-permissions-explained)
- Tìm hiểu về bash background jobs và Signal qua man pages.

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [ ] Commit message theo Conventional Commits (Sẽ check khi hoàn thành toàn bộ bài và commit).
- [x] Đã review lại code 1 lượt (Cho Part A).
