# Lý thuyết Week 5 - DevSecOps & MLOps

## Day 6: DAST (Dynamic Application Security Testing) & Gate Fail

### 1. Khái niệm DAST
Nếu SAST (Quét mã tĩnh) là việc kiểm tra bảo mật bằng cách phân tích kỹ từng dòng mã nguồn từ bên trong (Hộp trắng), thì **DAST** (Kiểm thử bảo mật ứng dụng động) là phương pháp tấn công vào hệ thống từ bên ngoài y hệt như một tin tặc thực thụ (Hộp đen).

DAST hoàn toàn không cần tiếp xúc với mã nguồn. Nó chỉ tương tác với ứng dụng thông qua giao diện Web (HTTP/HTTPS) hoặc API khi ứng dụng **đang thực sự hoạt động**.

#### Ưu điểm của DAST:
- **Phát hiện lỗi thời gian chạy (Runtime):** DAST tìm ra những lỗi mà SAST không thể thấy, ví dụ như lỗi cấu hình Server, cấu hình sai Header bảo mật, lỗi logic liên quan đến xác thực (Authentication), phân quyền (Authorization).
- **Tỉ lệ cảnh báo giả (False Positive) thấp:** Một khi DAST đã thâm nhập thành công và báo lỗi (ví dụ: chèn SQL thành công hoặc XSS thành công), điều đó đồng nghĩa với việc hệ thống chắc chắn 100% đã bị tổn thương.
- **Không phụ thuộc ngôn ngữ lập trình.**

#### Nhược điểm của DAST:
- Tốc độ quét chậm hơn SAST rất nhiều do phải gửi hàng ngàn HTTP request.
- Yêu cầu ứng dụng phải được Build và Deploy lên một môi trường (Staging/Test/Local) thì mới có thể tiến hành quét.

### 2. OWASP ZAP (Zed Attack Proxy)
Trong hệ sinh thái mã nguồn mở, **OWASP ZAP** là công cụ DAST phổ biến và mạnh mẽ nhất thế giới.
- Về bản chất, ZAP đóng vai trò như một Proxy trung gian đứng giữa Client và Server để đánh chặn, phân tích và sửa đổi các request.
- ZAP cung cấp cơ chế quét tự động (Automated Scanning) bao gồm 2 bước: **Spider** (rò quét toàn bộ URL/đường dẫn của ứng dụng) và **Active Scan** (bơm các payload độc hại như XSS, SQLi vào các URL vừa tìm được để tấn công).

### 3. Gate Fail trong CI/CD là gì?
Trong quá trình xây dựng pipeline DevSecOps, **Gate Fail** (hay Quality Gate) là cơ chế thiết lập các "Trạm kiểm soát an ninh". 
Thay vì chỉ chạy công cụ quét bảo mật rồi xuất báo cáo, cơ chế Gate Fail sẽ tự động phân tích báo cáo và so sánh với một **ngưỡng chịu đựng (Threshold)** đã được định nghĩa từ trước.

Ví dụ: 
- Nếu ZAP quét ra `>= 1` lỗ hổng mức **High/Critical**, tự động ngắt toàn bộ Pipeline (bằng cách trả về Exit Code `1`), cấm tuyệt đối việc Deploy lên môi trường Production.
- Cơ chế này đóng vai trò như một cảnh sát giao thông, ép buộc Lập trình viên phải ưu tiên vá các lỗ hổng bảo mật nghiêm trọng trước khi có thể ra mắt tính năng mới.
