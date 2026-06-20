# Part A — Networking primer

## 1. So sánh OSI 7 lớp với TCP/IP 4 lớp
- **OSI (7 layers)**: Application, Presentation, Session, Transport, Network, Data Link, Physical. (Đây là mô hình lý thuyết tham chiếu).
- **TCP/IP (4 layers)**: Application (gộp 3 lớp trên của OSI), Transport, Internet (tương đương Network), Network Access (gộp 2 lớp dưới cùng).
- **Khác biệt chính**: OSI tách biệt rất chi tiết việc biểu diễn dữ liệu và quản lý phiên kết nối thành các lớp riêng, còn TCP/IP gộp chung tất cả vào lớp Application để đơn giản hóa. TCP/IP được xây dựng dựa trên các giao thức thực tế (TCP, IP) nên linh hoạt hơn.

## 2. TCP 3-way handshake
**ASCII Diagram:**
```text
Client                                  Server
  |                                       |
  |  ------- SYN (seq=x) ---------------> | (1) Client gửi cờ SYN để xin kết nối
  |                                       |
  |  <------ SYN-ACK (seq=y, ack=x+1) --- | (2) Server đồng ý, gửi SYN-ACK xác nhận
  |                                       |
  |  ------- ACK (ack=y+1) -------------> | (3) Client nhận được, gửi ACK xác nhận lại
  |                                       |
```
**Giải thích các cờ:**
- **SYN (Synchronize)**: Dùng để khởi tạo kết nối và đồng bộ số thứ tự ban đầu (Sequence number).
- **ACK (Acknowledgment)**: Xác nhận đã nhận được gói tin từ bên kia (giá trị ack = seq đã nhận + 1).
- **FIN (Finish)**: Thông báo muốn đóng kết nối một cách an toàn, đảm bảo dữ liệu 2 bên đã gửi/nhận xong.
- **RST (Reset)**: Đóng kết nối ngay lập tức (thường xảy ra khi có lỗi phần cứng, ứng dụng crash, hoặc khi một port không có service nào lắng nghe bị gọi tới).

## 3. Khi nào chọn UDP thay TCP?
- **TCP**: Đảm bảo dữ liệu đến nơi đầy đủ, đúng thứ tự, sẽ truyền lại nếu mất gói. Có độ trễ cao hơn do phải handshake và xác nhận. Dùng cho cách giao thức yêu cầu thông tin nguyên vẹn, chính xác nhất như HTTP/HTTPS, Email, truyền file (SSH, FTP)...
- **UDP**: Truyền dữ liệu nhanh, không quan tâm gói tin có bị mất hay sai thứ tự hay không, không cần thiết lập kết nối trước. Dùng cho các hoạt động cần tốc độ nhanh, thậm chí tức thời và chấp nhận mất dữ liệu.
- **Ví dụ thực tế dùng UDP**: Livestream video, gọi video, game online có chế độ multiplayer, truy vấn tên miền DNS.

## 4. CIDR `/24`, `/16`, `/22` — số IP tương ứng
- IPv4 có tổng cộng 32 bits. Ký hiệu CIDR `/N` có nghĩa là lấy `N` bits để làm Network ID, còn lại `32 - N` bits làm Host ID.
- Số IP tối đa trong subnet = `2^(32 - N)`. Số IP khả dụng (có thể gán cho máy) = `Số IP tối đa - 2` (do trừ đi địa chỉ Network và địa chỉ Broadcast).
- **`/24`**: Dành ra `32 - 24 = 8` bits cho host. Số IP tối đa = `2^8 = 256`. Số IP khả dụng: **254**.
- **`/16`**: Dành ra `32 - 16 = 16` bits cho host. Số IP tối đa = `2^16 = 65,536`. Số IP khả dụng: **65,534**.
- **`/22`**: Dành ra `32 - 22 = 10` bits cho host. Số IP tối đa = `2^10 = 1,024`. Số IP khả dụng: **1,022**.

## 5. Tại sao có private IP range?
- Không gian địa chỉ IPv4 chỉ có khoảng 4.3 tỷ IP, đã cạn kiệt và không đủ để cấp cho mọi thiết bị trên thế giới.
- Các dải private IP (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) được quy ước để sử dụng cho các mạng nội bộ (LAN). Các thiết bị dùng IP này không thể giao tiếp trực tiếp trên môi trường Internet toàn cầu.
- Nhờ kết hợp với NAT, hàng nghìn thiết bị trong mạng nội bộ có thể chung nhau đi ra Internet thông qua chỉ 1 địa chỉ Public IP, giúp tiết kiệm tài nguyên IPv4.

## 6. NAT là gì? Phân biệt SNAT vs DNAT
- **NAT (Network Address Translation)**: Là cơ chế biên dịch địa chỉ IP (và có thể là cả Port) trong header của gói tin khi nó đi qua một Router hoặc Firewall biên.
  - **Mục đích**: Giải quyết bài toán cạn kiệt địa chỉ IPv4 bằng cách cho nhiều thiết bị chung 1 Public IP và tăng tính bảo mật.
  - **Cơ chế hoạt động (NAT Table)**: Khi Router dịch địa chỉ IP của một gói tin đi ra, nó lưu thông tin ánh xạ này vào một bảng gọi là Bảng NAT. Khi gói tin phản hồi từ Internet quay về, Router dựa vào bảng này để dịch ngược lại và trả về đúng máy khách trong mạng.

- **SNAT (Source NAT - Dịch IP nguồn)**: 
  - **Cách hoạt động**: Khi gói tin đi từ mạng nội bộ (LAN) ra Internet, router thay đổi IP Nguồn (Source IP) từ private IP thành public IP của router.
  - **Ứng dụng**: Cho phép các thiết bị nội bộ truy cập Internet mà không bị lộ danh tính.

- **DNAT (Destination NAT - Dịch IP đích / Port Forwarding)**:
  - **Cách hoạt động**: Khi gói tin đi từ Internet vào trong LAN, Router nhận thấy gói tin đến Public IP của mình trên một Port cụ thể, nó sẽ thay đổi IP đích thành private IP của máy nhận.
  - **Ứng dụng**: Publish các dịch vụ nội bộ (Web Server, Camera, Game Server) ra ngoài Internet cho người khác truy cập.

## 7. Forward Proxy vs Reverse Proxy
- **Forward Proxy**: Đứng làm đại diện cho **Client**. Traffic đi từ `Client -> Proxy -> Internet`. Proxy đi lấy dữ liệu thay mặt người dùng và trả về cho họ. Dùng để vượt tường lửa công ty, ẩn danh truy cập, hoặc lưu cache tiết kiệm băng thông nội bộ.
- **Reverse Proxy**: Đứng làm đại diện cho **Server**. Traffic đi từ `Internet -> Proxy -> Servers`. Nó ẩn đi cấu trúc server thực sự phía sau, đóng vai trò phân tải (Load Balancing), chặn DDoS, và tập trung cài đặt SSL/TLS. Ví dụ: Nginx, HAProxy.
