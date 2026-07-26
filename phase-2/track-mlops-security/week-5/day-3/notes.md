# Lý thuyết Week 5 - DevSecOps & MLOps

## Day 3: Security - SAST và SCA trong DevSecOps

### 1. Tổng quan về Shift-Left Security
Trong mô hình phát triển phần mềm truyền thống, kiểm tra bảo mật thường diễn ra ở giai đoạn cuối cùng (trước khi phát hành ra môi trường thực tế). Tuy nhiên, mô hình **DevSecOps** áp dụng triết lý **Shift-Left**, tức là đẩy các khâu kiểm tra bảo mật sang bên trái của chu trình (tích hợp ngay từ lúc viết mã nguồn, biên dịch và chạy CI/CD). Việc phát hiện sớm lỗ hổng giúp giảm thiểu tối đa chi phí và thời gian khắc phục sự cố. Hai kỹ thuật đóng vai trò trọng tâm trong khâu này là SAST và SCA.

### 2. SAST (Static Application Security Testing)

**Khái niệm:**
SAST, hay còn gọi là kiểm tra bảo mật hộp trắng (White-box testing), là phương pháp phân tích trực tiếp mã nguồn tĩnh (source code), bytecode hoặc binary mà không cần chạy ứng dụng lên.

**Mục tiêu:**
- Phát hiện các điểm yếu bảo mật phổ biến như SQL Injection, Cross-Site Scripting (XSS), Buffer Overflow hoặc tình trạng lạm dụng các hàm không an toàn.
- Báo cáo các đoạn mã không tuân thủ tiêu chuẩn lập trình an toàn.

**Đặc điểm:**
- Có thể thực hiện rất sớm trong chu trình phần mềm (ngay khi mã nguồn vừa được commit).
- Xác định và chỉ điểm vị trí chính xác của lỗi (tên file, số dòng) để kỹ sư sửa chữa ngay lập tức.
- Yếu điểm là thường tạo ra nhiều cảnh báo giả (False Positives) do công cụ chỉ phân tích cú pháp tĩnh mà không nắm được luồng dữ liệu lúc ứng dụng đang chạy.

**Công cụ tiêu biểu: Semgrep**
Semgrep là một công cụ SAST mã nguồn mở được thiết kế để phân tích mã nguồn cực nhanh và linh hoạt. Thay vì sử dụng các biểu thức chính quy (Regex) phức tạp dễ sai sót, Semgrep cho phép viết các luật (rules) phân tích bảo mật dưới dạng các đoạn code mẫu, giúp nhận diện và ngăn chặn mã độc hại một cách trực quan.

### 3. SCA (Software Composition Analysis)

**Khái niệm:**
Phần lớn các ứng dụng hiện đại được cấu thành từ 70% - 80% mã nguồn mở (Open-source libraries/dependencies) thuộc về bên thứ ba. SCA là kỹ thuật tự động phân tích và thống kê toàn bộ các thư viện này để rà soát xem chúng có chứa các lỗ hổng bảo mật đã được công bố trên toàn cầu (CVE - Common Vulnerabilities and Exposures) hay không.

**Mục tiêu:**
- Xây dựng danh sách minh bạch các thành phần phần mềm (BOM - Bill of Materials).
- Phát hiện thư viện lỗi thời, thư viện chứa lỗ hổng CVE nguy hiểm, hoặc vi phạm giấy phép sử dụng (License compliance).

**Đặc điểm:**
- Chỉ tập trung vào các file cấu hình và quản lý thư viện (ví dụ: `requirements.txt`, `package.json`, `go.mod`).
- Không hề phân tích phần mã nguồn logic do đội ngũ dự án tự viết (trách nhiệm này thuộc về SAST).

**Công cụ tiêu biểu: Snyk và Grype**
- **Snyk**: Cung cấp nền tảng toàn diện để quét lỗ hổng thư viện, đưa ra gợi ý nâng cấp phiên bản an toàn và thậm chí tự động sinh các Pull Request để vá lỗi hệ thống.
- **Grype**: Công cụ mã nguồn mở từ hãng Anchore, có sức mạnh vượt trội trong việc quét các file hệ thống tĩnh và container image để tìm ra các CVE, rất dễ tích hợp thẳng vào các luồng CI/CD pipeline.
