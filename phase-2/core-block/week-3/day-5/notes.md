# Lý thuyết Day 5: RBAC, ServiceAccount, NetworkPolicy

## 1. RBAC - Role-Based Access Control

RBAC là cơ chế quản lý quyền truy cập trong Kubernetes dựa trên vai trò của từng đối tượng. Hệ thống phân quyền này bao gồm 4 thành phần chính:
- **Role**: Định nghĩa tập hợp các quyền (như get, list, watch, create, delete) đối với các tài nguyên cụ thể (Pod, Secret, Service...). Role chỉ có tác dụng giới hạn trong một Namespace duy nhất.
- **RoleBinding**: Có nhiệm vụ liên kết một Role với một đối tượng (User hoặc ServiceAccount). Khi được liên kết, đối tượng đó sẽ sở hữu các quyền được định nghĩa trong Role ở phạm vi Namespace tương ứng.
- **ClusterRole**: Giống hệt như Role, nhưng phạm vi hoạt động bao trùm lên toàn bộ Cluster. Nó có thể kiểm soát các tài nguyên ở mọi Namespace hoặc các tài nguyên cấp Cluster (như Node).
- **ClusterRoleBinding**: Có nhiệm vụ liên kết ClusterRole với một đối tượng, cấp quyền truy cập cho đối tượng đó trên phạm vi toàn Cluster.

## 2. Service Accounts

Trong Kubernetes, User là khái niệm dành cho con người (nhà phát triển, quản trị viên) thao tác từ bên ngoài. Ngược lại, ServiceAccount được thiết kế dành riêng cho các tiến trình hoặc ứng dụng chạy bên trong Pod.
- Khi một Pod được khởi tạo, nó có thể được cấu hình để sử dụng một ServiceAccount.
- Kubernetes sẽ tự động đưa (inject) một đoạn mã Token vào bên trong Container của Pod đó.
- Ứng dụng đang chạy có thể trích xuất Token này để xác thực và gửi yêu cầu đến máy chủ Kubernetes API. Mức độ truy cập của ứng dụng hoàn toàn phụ thuộc vào việc ServiceAccount đó được gắn với Role nào.

## 3. Network Policies

Mặc định, Kubernetes cho phép tất cả các Pod trong một Cluster giao tiếp tự do với nhau mà không có rào cản nào. NetworkPolicy đóng vai trò như một bức tường lửa để kiểm soát luồng giao thông mạng này.
- **Luật Ingress**: Kiểm soát luồng đi vào một Pod.
- **Luật Egress**: Kiểm soát luồng đi ra khỏi một Pod.
- Cơ chế hoạt động của NetworkPolicy là cộng dồn (additive) và mặc định là từ chối (default deny). Nghĩa là, khi một Pod lọt vào tầm ngắm của bất kỳ NetworkPolicy nào, nó sẽ lập tức chặn đứng mọi kết nối ngoại trừ những kết nối được liệt kê rõ ràng trong danh sách cho phép (allow-list).
- Triển khai một NetworkPolicy khóa toàn bộ luồng Ingress (deny-all) cho cả Namespace, rồi sau đó mới mở dần kết nối cho từng nhóm Pod cụ thể là một phương pháp thiết kế mạng an toàn và rất được khuyến nghị.