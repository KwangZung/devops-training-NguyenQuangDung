# Lý thuyết Week 6 - Day 4: OPA Gatekeeper

## 1. OPA Gatekeeper là gì?
Open Policy Agent (OPA) là một open-source policy engine có chức năng tách biệt (decouple) việc quyết định chính sách ra khỏi mã nguồn ứng dụng. 

Mặc dù OPA có thể được áp dụng cho nhiều hệ thống (như Microservices, CI/CD, Terraform), OPA Gatekeeper được phát triển riêng để tích hợp với Kubernetes.
Gatekeeper hoạt động dưới dạng Kubernetes Admission Controller. Công cụ này tiếp nhận và đánh giá mọi request (tạo Pod, Service, Ingress...) gửi đến API Server dựa trên các policy do người quản trị định nghĩa, từ đó đưa ra quyết định chấp thuận hoặc từ chối request.

## 2. Gatekeeper vs Pod Security Admission (PSA)
Sự khác biệt chính giữa PSA và Gatekeeper:
- **PSA**: Quy trình cài đặt đơn giản thông qua label, nhưng chỉ hỗ trợ 3 tiêu chuẩn cố định (Privileged, Baseline, Restricted).
- **Gatekeeper**: Yêu cầu định nghĩa policy bằng ngôn ngữ Rego, cung cấp khả năng tùy biến linh hoạt. Quản trị viên có thể viết policy để giới hạn bất kỳ tài nguyên nào:
  - Từ chối sử dụng image có tag `:latest`.
  - Bắt buộc Namespace phải chứa các label định danh (ví dụ: `team=data` hoặc `team=backend`).
  - Ngăn chặn Ingress sử dụng trùng domain nhằm chống hostname collision.
  - Yêu cầu cấu hình CPU/Memory Limits cho tất cả các Pod.

*(Quy trình này thể hiện khái niệm Policy as Code - quản lý chính sách bảo mật thông qua mã nguồn)*.

## 3. Kiến trúc hoạt động của Gatekeeper
Gatekeeper tận dụng cơ chế Kubernetes Custom Resource Definitions (CRDs). Việc áp dụng một policy yêu cầu 2 thành phần:

### A. ConstraintTemplate
- Đóng vai trò định nghĩa logic của policy thông qua ngôn ngữ Rego.
- Khai báo các tham số đầu vào và mã Rego dùng để đánh giá request.
- Khi áp dụng ConstraintTemplate, Gatekeeper sẽ tự động tạo ra một CRD tương ứng.

### B. Constraint
- Là phiên bản thực thi của ConstraintTemplate trên Cluster.
- Constraint không chứa mã Rego, chỉ làm nhiệm vụ khai báo phạm vi áp dụng (ví dụ: áp dụng cho Namespace nào, Resource nào) và truyền các tham số cụ thể (ví dụ: các tag bị cấm).

## 4. Ngôn ngữ Rego cơ bản
- Rego là ngôn ngữ khai báo logic (declarative) mặc định của OPA.
- Cấu trúc tiêu chuẩn trong Gatekeeper:
  ```rego
  violation[{"msg": msg}] {
      # Lấy danh sách containers từ input
      container := input.review.object.spec.containers[_]
      
      # Kiểm tra điều kiện vi phạm
      endswith(container.image, ":latest")
      
      # Khai báo thông báo lỗi
      msg := sprintf("Container <%v> uses a forbidden :latest tag", [container.name])
  }
  ```
- Ý nghĩa: Nếu tất cả các mệnh đề bên trong khối `{}` trả về giá trị True, một đối tượng `violation` sẽ được sinh ra, khiến Gatekeeper từ chối request.

## 5. Gatekeeper Library
Nhằm giảm thiểu thời gian phát triển policy bằng Rego, cộng đồng OPA cung cấp Gatekeeper Library. Đây là bộ sưu tập các ConstraintTemplate phổ biến, cho phép áp dụng ngay lập tức các tính năng bảo mật (như từ chối chạy quyền Root hoặc Privileged mode) với độ linh hoạt cao hơn PSA.
