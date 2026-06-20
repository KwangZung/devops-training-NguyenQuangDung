# Part D: Phân tích gói tin TCP

## 1. Phân tích thứ tự các packet

**A. Giai đoạn thiết lập kết nối**
Đây là ba gói tin khởi tạo kết nối giữa client (`172.17.250.203`) và server của Google.
1. **[SYN]:** Client gửi cờ `[S]` báo hiệu yêu cầu mở kết nối.
   ```text
   04:34:52.516068 eth0 Out IP 172.17.250.203.57568 > nchkgb-al-in-f14.1e100.net.http: Flags [S], seq 1805927523...
   ```
2. **[SYN, ACK]:** Server nhận yêu cầu và phản hồi bằng cờ `[S.]` để đồng ý và xác nhận.
   ```text
   04:34:52.576034 eth0 In IP nchkgb-al-in-f14.1e100.net.http > 172.17.250.203.57568: Flags [S.], seq 1822328249, ack 1805927524...
   ```
3. **[ACK]:** Client phản hồi bằng cờ `[.]` để xác nhận quá trình thiết lập. Kết nối TCP được thiết lập thành công.
   ```text
   04:34:52.576221 eth0 Out IP 172.17.250.203.57568 > nchkgb-al-in-f14.1e100.net.http: Flags [.], ack 1...
   ```

**B. Giai đoạn trao đổi dữ liệu**
Quá trình truyền tải dữ liệu HTTP (port 80) được thực hiện dưới dạng văn bản không mã hóa.
4. **[PSH, ACK]:** Client đóng gói và truyền tải yêu cầu HTTP GET.
   ```text
   04:34:52.576551 eth0 Out IP 172.17.250.203.57568 > ... Flags [P.], seq 1:74, ack 1... length 73: HTTP: GET / HTTP/1.1
   GET / HTTP/1.1
   Host: google.com
   User-Agent: curl/8.5.0
   ```
5. **[ACK]:** Server gửi tín hiệu xác nhận đã nhận được 73 byte yêu cầu.
   ```text
   04:34:52.634705 eth0 In IP nchkgb-al-in-f14.1e100.net.http > ... Flags [.], ack 74...
   ```
6. **[PSH, ACK]:** Server đóng gói dữ liệu và trả về phản hồi HTTP 301 cùng với nội dung HTML.
   ```text
   04:34:52.659332 eth0 In IP nchkgb-al-in-f14.1e100.net.http > ... Flags [P.], seq 1:774, ack 74... length 773: HTTP: HTTP/1.1 301 Moved Permanently
   HTTP/1.1 301 Moved Permanently
   Location: http://www.google.com/
   ...
   <H1>301 Moved</H1>
   ```
7. **[ACK]:** Client xác nhận đã nhận đủ 773 byte nội dung từ server.
   ```text
   04:34:52.659458 eth0 Out IP 172.17.250.203.57568 > ... Flags [.], ack 774...
   ```

**C. Giai đoạn đóng kết nối**
Sau khi trao đổi dữ liệu xong, tiến trình đóng kết nối được kích hoạt:
8. **[FIN, ACK]:** Client gửi cờ `[F.]` yêu cầu ngắt kết nối.
   ```text
   04:34:52.659927 eth0 Out IP 172.17.250.203.57568 > ... Flags [F.], seq 74, ack 774...
   ```
9. **[FIN, ACK]:** Server gửi gói `[F.]` xác nhận yêu cầu của client và thông báo kết thúc việc gửi dữ liệu.
   ```text
   04:34:52.716773 eth0 In IP nchkgb-al-in-f14.1e100.net.http > ... Flags [F.], seq 774, ack 75...
   ```
10. **[ACK]:** Client gửi gói `[.]` cuối cùng để hoàn tất việc giải phóng kết nối TCP.
   ```text
   04:34:52.716853 eth0 Out IP 172.17.250.203.57568 > ... Flags [.], ack 775...
   ```

## 2. Câu hỏi 2

**1. Đã bắt được request đầy đủ chưa?**

Kết quả thực tế cho thấy hệ thống đã bắt được toàn bộ nội dung dữ liệu. Do giao thức sử dụng ở đây là HTTP, dữ liệu được truyền tải ở định dạng văn bản không mã hóa. Bằng công cụ *tcpdump* hoặc *Wireshark*, có thể trích xuất và phân tích toàn vẹn nội dung của cả thông tin tiêu đề lẫn nội dung thân trang (bao gồm mã nguồn HTML).

**2. Vì sao HTTPS không bắt được payload?**

Đầu tiên, khi truy cập qua giao thức HTTPS (cổng 443), ba bước thiết lập kết nối ban đầu vẫn diễn ra bình thường và có thể được chụp lại dưới dạng văn bản không mã hóa.

Tiếp theo, ngay sau quá trình khởi tạo TCP, hệ thống sẽ tiến hành quá trình bắt tay TLS để trao đổi bộ mã hóa và trao đổi khóa phiên.

Cuối cùng, kể từ thời điểm bắt tay TLS hoàn tất, toàn bộ dữ liệu ở tầng ứng dụng bao gồm yêu cầu HTTP, thông tin tiêu đề và nội dung trả về đều được mã hóa hoàn toàn. Vì vậy, dù công cụ bắt gói lưu lại được đầy đủ các gói tin truyền qua card mạng, nội dung bên trong gói tin chỉ hiển thị dưới dạng chuỗi nhị phân ngẫu nhiên không thể đọc hiểu, đảm bảo tính bảo mật cho dữ liệu trên đường truyền.
