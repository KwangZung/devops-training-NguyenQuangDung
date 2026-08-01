# Lý thuyết Week 5 - DevSecOps & MLOps

## Day 4: Security - Secret Scanning (Quét rò rỉ thông tin nhạy cảm)

### 1. Khái niệm Secret Scanning
Trong quá trình phát triển phần mềm và xây dựng mô hình AI, các lập trình viên thường xuyên phải làm việc với các hệ thống bên thứ ba (Cơ sở dữ liệu, Cloud Provider như AWS/GCP, hoặc các API Services). Việc vô tình mã hóa cứng (hardcode) các thông tin xác thực như Mật khẩu (Passwords), Khóa truy cập (API Keys, Tokens, AWS Secret Keys) trực tiếp vào mã nguồn là một trong những rủi ro bảo mật nghiêm trọng và phổ biến nhất.

**Secret Scanning** là kỹ thuật tự động quét toàn bộ mã nguồn hiện tại cũng như lịch sử thay đổi (Git history) để dò tìm, cảnh báo và ngăn chặn các thông tin nhạy cảm này bị rò rỉ ra bên ngoài (ví dụ: vô tình đẩy lên GitHub công khai).

### 2. Sự nguy hiểm của việc rò rỉ Secret trong Git History
Một sai lầm chí mạng rất phổ biến là khi lập trình viên phát hiện mình lỡ hardcode Secret, họ thường chỉ xóa dòng code đó đi và tạo một commit mới. Tuy nhiên, bản chất của hệ thống quản lý phiên bản (như Git) là lưu giữ **mọi thay đổi trong quá khứ**. 

Điều này có nghĩa là Secret không hề biến mất mà vẫn nằm nguyên vẹn trong các commit cũ (Git history). Bất kỳ ai clone repository về đều có thể dễ dàng sử dụng các lệnh như `git log` hoặc `git diff` để đào xới và trích xuất lại đoạn Secret đã bị xóa đó. 

Chính vì vậy, Secret Scanning không chỉ có nhiệm vụ quét các file ở trạng thái hiện hành (workspace), mà bắt buộc phải có khả năng lội ngược dòng thời gian để quét rà soát toàn bộ lịch sử commit.

### 3. Các công cụ Secret Scanning tiêu biểu
Mặc dù các công cụ SAST (như Semgrep ở Day 3) có thể được ép cấu hình để quét Secret, nhưng chúng thường không chuyên dụng và rất dễ bỏ sót các lỗ hổng nằm sâu trong lịch sử Git. Trong luồng DevSecOps thực tế, các chuyên gia thường tích hợp các công cụ chuyên dụng sau vào hệ thống CI/CD hoặc Pre-commit hook:

#### a. Gitleaks
- **Đặc điểm:** Là công cụ mã nguồn mở vô cùng phổ biến, được viết bằng ngôn ngữ Go nên tốc độ quét cực kỳ nhanh.
- **Cách thức hoạt động:** Sử dụng kết hợp các biểu thức chính quy (Regex) phức tạp và thuật toán tính toán độ hỗn loạn (Entropy) để nhận diện chính xác hàng trăm loại API Key/Token khác nhau (từ AWS, GitHub, Slack, cho đến Stripe).
- **Ưu điểm:** Khả năng quét cạn kiệt toàn bộ lịch sử Git repository (từ commit đầu tiên cho đến hiện tại) vô cùng hoàn hảo.

#### b. TruffleHog
- **Đặc điểm:** Một công cụ mã nguồn mở cực mạnh khác, tiến xa hơn rất nhiều so với việc chỉ dựa vào Regex hay Entropy.
- **Cách thức hoạt động:** Tính năng làm nên tên tuổi của TruffleHog là khả năng **tự động xác thực (Auto-verification)**. Khi TruffleHog phát hiện một đoạn mã khả nghi giống AWS Key, nó sẽ tự động thử gửi một API request ẩn danh đến server của AWS để kiểm tra xem Key đó có thực sự đang hoạt động (active/valid) hay không.
- **Ưu điểm:** Giảm thiểu tối đa tình trạng cảnh báo giả (False Positives). Một khi TruffleHog gióng lên hồi chuông báo động, điều đó đồng nghĩa Secret đó 100% là hàng thật và hệ thống đang trong tình trạng bị đe dọa thực sự.
