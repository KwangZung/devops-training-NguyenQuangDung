# Lý thuyết Week 6 - Day 4: OPA Gatekeeper

## 1. OPA Gatekeeper là gì?
**Open Policy Agent (OPA)** là một open-source policy engine, giúp tách biệt (decouple) việc ra quyết định chính sách ra khỏi mã nguồn ứng dụng. 

Tuy nhiên, OPA có thể dùng cho bất cứ hệ thống nào (Microservices, CI/CD, Terraform...). Để áp dụng riêng cho Kubernetes, cộng đồng đã tạo ra **OPA Gatekeeper**.
Gatekeeper hoạt động như một **Kubernetes Admission Controller**. Nó đứng gác ở cửa (như một anh bảo vệ), chặn hoặc cho phép mọi request (tạo Pod, Service, Ingress, v.v.) gửi đến API Server dựa trên các luật (policy) do chúng ta tự định nghĩa.

## 2. Gatekeeper vs Pod Security Admission (PSA)
Ở Day 3, ta đã học về PSA. Vậy tại sao lại cần Gatekeeper?
- **PSA**: Rất dễ cài đặt (chỉ cần gắn label), nhưng cực kỳ cứng nhắc. Nó chỉ có 3 chuẩn cố định (Privileged, Baseline, Restricted).
- **Gatekeeper**: Khó cài đặt hơn, yêu cầu học ngôn ngữ Rego, nhưng **linh hoạt vô hạn**. Bạn có thể viết luật cấm bất cứ thứ gì:
  - Cấm sử dụng image có tag `:latest`.
  - Bắt buộc mọi Namespace phải có nhãn `team=data` hoặc `team=backend`.
  - Cấm Ingress sử dụng trùng domain (chống Hostname collision).
  - Yêu cầu cấu hình CPU/Memory Limits cho tất cả các Pod.

*(Đây chính là khái niệm **Policy as Code** - Quản lý chính sách bảo mật bằng mã code)*.

## 3. Kiến trúc hoạt động của Gatekeeper
Gatekeeper sử dụng cơ chế của Kubernetes Custom Resource Definitions (CRDs). Để áp dụng một luật mới, ta cần 2 mảnh ghép:

### A. ConstraintTemplate (Khuôn mẫu chính sách)
- Đóng vai trò định nghĩa **Logic** của luật bằng ngôn ngữ **Rego**.
- Nó định nghĩa tham số đầu vào (nếu có) và mã Rego để kiểm tra xem một request có hợp lệ hay không.
- Sau khi apply `ConstraintTemplate`, Gatekeeper sẽ động tạo ra một CRD mới.

### B. Constraint (Áp dụng chính sách)
- Khi đã có khuôn (Template), ta tạo ra các Constraint để **Áp dụng** khuôn đó vào Cluster.
- Constraint không chứa code Rego, nó chỉ khai báo: Áp dụng cái khuôn này cho Namespace nào, Resource nào (Pod hay Service?), và truyền vào các tham số (ví dụ: cấm tag gì).

## 4. Ngôn ngữ Rego cơ bản
- Rego là ngôn ngữ logic (declarative) được OPA sử dụng.
- Cấu trúc thường gặp trong Gatekeeper:
  ```rego
  violation[{"msg": msg}] {
      # Mệnh đề 1: Lấy danh sách containers từ input
      container := input.review.object.spec.containers[_]
      
      # Mệnh đề 2: Kiểm tra điều kiện vi phạm
      endswith(container.image, ":latest")
      
      # Mệnh đề 3: Trả về thông báo lỗi
      msg := sprintf("Container <%v> uses a forbidden :latest tag", [container.name])
  }
  ```
- Ý nghĩa: Nếu toàn bộ các mệnh đề bên trong khối `{}` trả về **True**, một `violation` (vi phạm) sẽ được tạo ra, và Gatekeeper sẽ **từ chối** request đó.

## 5. Gatekeeper Library
Vì việc học viết Rego mất rất nhiều thời gian, cộng đồng OPA đã tạo sẵn một kho tàng các Template phổ biến gọi là **Gatekeeper Library**. Ta chỉ việc copy các ConstraintTemplate này về và sử dụng, bao gồm cả việc chặn chạy quyền Root, chặn Privileged mode y hệt như PSA nhưng linh hoạt hơn!
