# Task Submission Template

> Mỗi task = 1 thư mục con + 1 PR/MR riêng. Copy template này vào `README.md` của task.

## Task: `Day 4 — Networking Essentials`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 1 / Week 1 / Day 4`
- **Branch**: `phase-1/week-1/day-4-networking`
- **Submitted at**: `2026-19-06 23:00`
- **Time spent**: `5h`

## 1. Mục tiêu
- Hiểu mô hình OSI / TCP-IP layers.
- Phân biệt TCP vs UDP, biết khi nào dùng cái nào.
- Đọc & phân tích HTTP/HTTPS request bằng `curl -v`, `tcpdump`, `wireshark`.
- Hiểu DNS resolution, A/AAAA/CNAME/MX/TXT record.
- Biết khái niệm TLS handshake, certificate chain.

## 2. Cách chạy
```bash
# (Hướng dẫn chi tiết từng phần A, B, C, D, E sẽ cập nhật ở đây)
```

## 3. Kết quả
- Screenshot / log output (kèm trong `./screenshots/`).
- Chi tiết câu trả lời ở các file: `notes.md`, `dns-lab.md`, `tls-lab.md`, `tcpdump-lab.md`.

## 4. Khó khăn & cách giải quyết
- **Lỗi `dig +trace` bị timeout trên môi trường WSL2**: 
  - **Vấn đề**: Khi chạy lệnh `dig +trace google.com`, lệnh bị lỗi `;; communications error to 10.255.255.254#53: timed out` không thể kết nối tới DNS cục bộ, mặc dù lệnh `ping google.com` vẫn phân giải và chạy bình thường.
  - **Nguyên nhân**: WSL2 tự động tạo file `/etc/resolv.conf` trỏ về IP của vSwitch ảo nối với máy host Windows (ví dụ `10.255.255.254`). Lệnh `dig` tạo các gói UDP Raw nã trực tiếp vào IP này nhưng cấu hình Firewall/NAT của Windows thường sẽ drop/chặn các gói truy vấn Root Server trực tiếp từ trong môi trường ảo bắn ra. Trong khi đó, `ping` dùng hàm cấp cao của OS nên vẫn lấy được IP.
  - **Cách giải quyết**: Ép lệnh `dig` đi vòng qua DNS ảo của WSL và truy vấn trực tiếp lên Public DNS ngoài Internet (ví dụ dùng 8.8.8.8 của Google). Cú pháp: `dig @8.8.8.8 +trace google.com`.
## 5. Reference
- **Nguồn tài liệu cho Part A (Lý thuyết cơ bản)**:
  - So sánh OSI/TCP-IP, CIDR, NAT, Proxy: Lấy từ kiến thức mạng căn bản (giáo trình CCNA/Network+) và các quy chuẩn mạng như [RFC 1918 (Private IP)](https://datatracker.ietf.org/doc/html/rfc1918).
  - Kiến thức phân tích chi tiết TCP & UDP: Lấy từ [High Performance Browser Networking — Ch.1, 2 (free)](https://hpbn.co/).
- **Nguồn tài liệu cho Part B, C, D (Thực hành HTTPS, DNS, TCPDump)**:
  - Phân tích cơ chế hoạt động của HTTPS: [How HTTPS works — comic](https://howhttps.works/)
  - Sách HDSD các lệnh trên Linux: `man tcpdump`, `man dig`.

## 6. Self-check
- [ ] Code chạy được trên máy sạch.
- [ ] README có hướng dẫn run lại.
- [ ] Không hard-code secret.
- [ ] Commit message theo Conventional Commits.
- [ ] Đã review lại code 1 lượt.
