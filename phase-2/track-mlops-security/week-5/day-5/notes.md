# Lý thuyết Week 5 - DevSecOps & MLOps

## Day 5: Container Security & Image Scanning (Bảo mật Container và Quét lỗ hổng Image)

### 1. Khái niệm Container Security
Trong kiến trúc vi dịch vụ (Microservices) và luồng MLOps hiện đại, Docker Container là tiêu chuẩn vàng để đóng gói và triển khai ứng dụng. Tuy nhiên, sự tiện lợi này đi kèm với rủi ro lớn. Việc sử dụng các Base Image có sẵn trên mạng (ví dụ: `python:3.9-slim`, `ubuntu:latest`) tiềm ẩn nguy cơ chứa các lỗ hổng hệ điều hành (OS vulnerabilities) chưa được vá.

**Container Security** là tập hợp các phương pháp nhằm bảo mật toàn bộ vòng đời của một Container, bao gồm hai giai đoạn chính:
- **Build-time (Lúc đóng gói):** Rà quét lỗ hổng bên trong Docker Image và kiểm tra các cấu hình sai lầm trước khi đẩy (push) lên Container Registry.
- **Runtime (Lúc thực thi):** Thiết lập các rào cản bảo vệ khi Container đang chạy (ví dụ: cấm chạy bằng quyền root, giới hạn tài nguyên CPU/RAM để chống tấn công DoS).

### 2. Sự nguy hiểm của Docker Image không an toàn
- **Lỗ hổng cấp độ OS (CVE):** Các thư viện lõi của hệ điều hành bên trong base image như `glibc`, `openssl`, hay `curl` có thể dính các lỗ hổng CVE nghiêm trọng, tạo lỗ hổng cho tin tặc khai thác từ xa.
- **Cấu hình sai (Misconfiguration):** Một lỗi phổ biến là để ứng dụng chạy bằng quyền `root` tối cao bên trong Container. Dù Container đã được cô lập (isolated), nhưng nếu xảy ra lỗi leo thang đặc quyền (Privilege Escalation) ở tầng Kernel, tin tặc có thể "vượt ngục" thoát khỏi Container và chiếm quyền điều khiển toàn bộ máy chủ vật lý (Host).
- **Rò rỉ thông tin nhạy cảm:** Nếu vô tình sử dụng lệnh `COPY . .` mang theo các file `.env` hoặc file chứa cấu hình Secret vào bên trong Image, kẻ gian có thể tải Image đó về, giải nén và đánh cắp dễ dàng.

### 3. Image Scanning với Trivy
**Trivy** (phát triển bởi Aqua Security) hiện đang là công cụ quét lỗ hổng mã nguồn mở toàn diện và phổ biến nhất dành cho Container.

#### a. Đặc điểm nổi bật của Trivy
- **Quét đa tầng (All-in-one):** Trivy không chỉ quét lỗ hổng hệ điều hành (Alpine, RHEL, Ubuntu) mà còn kiêm luôn cả việc quét thư viện ứng dụng (tương tự Grype/SCA) và dò tìm Secret bị nhét nhầm vào Image (tương tự TruffleHog).
- **Misconfiguration Scanning (Quét cấu hình sai):** Trivy có khả năng phân tích trực tiếp file `Dockerfile` để đưa ra lời khuyên hoặc cảnh báo nếu phát hiện cấu hình nguy hiểm (chẳng hạn như thiếu lệnh `USER` để chuyển quyền).
- **Tốc độ cực nhanh:** Trivy là dạng stateless (không cần duy trì database cục bộ cồng kềnh), rất nhẹ, cực kỳ lý tưởng để nhúng thẳng vào các luồng CI/CD (như GitHub Actions hay GitLab CI).

#### b. Luồng hoạt động (Workflow) chuẩn trong CI/CD
1. Lập trình viên thiết kế `Dockerfile` và đẩy code lên kho lưu trữ.
2. CI Pipeline kích hoạt, tiến hành build mã nguồn thành một Docker Image hoàn chỉnh.
3. **Trivy can thiệp:** Tiến hành quét Image vừa build. Nếu phát hiện lỗ hổng ở mức độ CAO (High/Critical) chưa được vá, Pipeline sẽ bị đánh rớt (Failed) ngay lập tức, chặn đứng luồng làm việc.
4. Nếu vượt qua bài kiểm tra an toàn, Image mới được phép đẩy lên Docker Hub hoặc AWS ECR để sẵn sàng cho quy trình triển khai (Deployment).
