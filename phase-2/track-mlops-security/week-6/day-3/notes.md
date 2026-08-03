# Lý thuyết Week 6 - Day 3: Pod Security Admission (PSA)

## 1. Tổng quan về Pod Security Admission (PSA)
Trong các phiên bản Kubernetes trước đây, việc quản lý quyền bảo mật của Pod được thực hiện thông qua PodSecurityPolicy (PSP). Do tính phức tạp trong vận hành, PSP đã bị loại bỏ từ Kubernetes v1.21 và không còn tồn tại từ bản v1.25.

Kubernetes giới thiệu Pod Security Admission (PSA) như một giải pháp thay thế. PSA là một admission controller tích hợp sẵn, cho phép kiểm soát quyền bảo mật của Pod thông qua việc gán label trực tiếp lên các Namespace. 

PSA hoạt động dựa trên các tiêu chuẩn bảo mật được gọi là Pod Security Standards (PSS).

## 2. Pod Security Standards (PSS)
PSS định nghĩa 3 profile từ mức độ lỏng lẻo đến khắt khe nhất:

1. **Privileged**:
   - Mục đích: Không áp dụng bất kỳ hạn chế nào đối với Pod.
   - Đặc điểm: Cho phép Pod truy cập hệ điều hành của Node, bao gồm quyền root, hostNetwork, hostPath, privileged mode.
   - Ứng dụng: Cấu hình các Agent hệ thống, CNI plugin, CSI driver hoặc các công cụ monitoring cấp thấp.

2. **Baseline**:
   - Mục đích: Ngăn chặn các rủi ro bảo mật phổ biến trong khi duy trì khả năng tương thích cho phần lớn các ứng dụng.
   - Đặc điểm: Ngăn chặn Pod chạy ở chế độ privileged, không cho phép chia sẻ host network/PID/IPC namespaces, hạn chế mount các hostPath.
   - Ứng dụng: Áp dụng mặc định cho các ứng dụng thông thường không yêu cầu đặc quyền.

3. **Restricted**:
   - Mục đích: Áp dụng các tiêu chuẩn bảo mật khắt khe nhất theo best practices.
   - Đặc điểm: Kế thừa tất cả các giới hạn của Baseline, kèm theo các yêu cầu bổ sung:
     - Bắt buộc Pod chạy dưới quyền non-root (runAsNonRoot: true).
     - Bắt buộc cấu hình seccomp profile an toàn.
     - Drop các capabilities của Linux để chỉ cấp đúng quyền cần thiết.
   - Ứng dụng: Phù hợp cho các ứng dụng xử lý dữ liệu nhạy cảm, hệ thống tài chính hoặc môi trường Zero-Trust.

## 3. Chế độ hoạt động (Modes)
PSA hỗ trợ áp dụng các Profile trên theo 3 mode độc lập:

- **Enforce**: Hành động nghiêm ngặt nhất. Nếu Pod được tạo vi phạm Profile, PSA sẽ từ chối việc tạo Pod.
- **Audit**: Pod vẫn được tạo thành công, tuy nhiên một audit event sẽ được ghi nhận vào hệ thống Audit Log của Kubernetes.
- **Warn**: Pod vẫn được tạo thành công, đồng thời PSA trả về thông báo warning trực tiếp ra terminal khi người dùng thực thi lệnh.

Kubernetes cho phép cấu hình kết hợp nhiều mode trên cùng một Namespace. Ví dụ: Cấu hình enforce theo chuẩn Baseline, đồng thời thiết lập warn theo chuẩn Restricted.

## 4. Cấu hình PSA
Cấu hình PSA được thực hiện bằng cách gán Label vào Namespace theo cú pháp:
`pod-security.kubernetes.io/<MODE>: <PROFILE>`

**Ví dụ:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ns-restricted
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
```

## 5. Vai trò của PSA trong DevOps
Việc vận hành container bằng quyền root mặc định mang lại các rủi ro bảo mật nghiêm trọng. Nếu container bị khai thác, kẻ tấn công có thể lợi dụng lỗi leo thang đặc quyền để vượt qua khỏi giới hạn container (Container Breakout) và chiếm quyền hệ thống vật lý.
PSA cung cấp một lớp phòng thủ tự động cho hệ thống Kubernetes. Công cụ này giới hạn quyền triển khai các Pod độc hại hoặc chạy quyền root trái phép vào môi trường Production, đảm bảo mọi thành phần phải tuân thủ chuẩn baseline hoặc restricted theo chính sách vận hành.
