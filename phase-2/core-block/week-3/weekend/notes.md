# Week 3 - Weekend: Helm Chart, HPA/VPA

## 1. Horizontal Pod Autoscaler (HPA)

**Khái niệm**
HPA là cơ chế tự động điều chỉnh số lượng Pod của một ứng dụng dựa trên mức độ sử dụng tài nguyên thực tế.

**Cơ chế hoạt động**
- HPA hoạt động theo một chu kỳ vòng lặp, liên tục truy vấn Metrics Server để lấy số liệu thống kê về việc sử dụng CPU hoặc Memory của các Pod.
- Khi nhận thấy mức độ sử dụng trung bình vượt qua phần trăm mục tiêu được cấu hình, HPA sẽ tính toán số lượng Pod cần thiết mới và cập nhật vào cấu hình Deployment.
- Hệ thống Kubernetes sau đó sẽ sinh thêm Pod mới để san sẻ tải. Ngược lại, khi mức tải giảm xuống, HPA sẽ tự động giảm số lượng Pod để giải phóng tài nguyên Cluster.

**Lưu ý quan trọng**
- Ứng dụng bắt buộc phải được khai báo thông số giới hạn tài nguyên thì HPA mới có cơ sở toán học để tính toán tỷ lệ phần trăm sử dụng.

## 2. Vertical Pod Autoscaler (VPA)

**Khái niệm**
VPA là cơ chế tự động phân tích và điều chỉnh cấu hình phần cứng cho từng Container bên trong Pod.

**Cơ chế hoạt động**
- VPA theo dõi quá trình sử dụng tài nguyên của Pod để liên tục tính toán và đưa ra các đề xuất cấu hình phù hợp nhất.
- Khi được đặt ở chế độ tự động, nếu phát hiện Pod đang chạy với tài nguyên quá thấp so với nhu cầu, VPA sẽ ra lệnh gỡ bỏ Pod cũ và tạo ra Pod mới được cấp phát lượng CPU và Memory dồi dào hơn.
- Ngược lại, nếu Pod đang chiếm giữ quá nhiều tài nguyên mà không dùng hết, VPA sẽ thu hẹp thông số lại ở lần khởi động Pod tiếp theo.

**Xung đột hệ thống**
- Kubernetes khuyến cáo tuyệt đối không bật HPA (dựa trên CPU hoặc Memory) và VPA trên cùng một tập hợp Pod, vì hai tính năng này sẽ tranh giành quyền kiểm soát dẫn đến những kết quả hệ thống không lường trước được.

## 3. Helm và Helm Chart

**Helm là gì?**
- Helm đóng vai trò là một trình quản lý gói dành cho Kubernetes. Nó giúp đơn giản hóa quá trình cài đặt, nâng cấp và quản lý các ứng dụng phức tạp có nhiều thành phần liên kết với nhau.

**Helm Chart là gì?**
- Chart là một cấu trúc folder chứa các file cấu hình YAML định nghĩa một ứng dụng hoàn chỉnh.
- Thay vì phải viết cứng các file YAML riêng lẻ, Chart cho phép sử dụng hệ thống template kết hợp với các biến cấu hình động.

**Cấu trúc chính của một Chart**
- **Chart.yaml**: File chứa thông tin metadata khai báo tên phần mềm, phiên bản ứng dụng.
- **values.yaml**: File chứa các biến cấu hình mặc định. Người dùng có thể thay đổi các giá trị trong file này (như đổi tên image, đổi Port mạng) mà không cần can thiệp vào cấu trúc mã nguồn gốc.
- Folder **templates/**: Chứa các file YAML mẫu. Khi cài đặt, Helm sẽ tự động đọc các tham số từ file `values.yaml` và inject vào các file mẫu này để hoàn thiện bộ cấu hình trước khi gửi lên Cluster.
