# Lý thuyết Week 6 - Day 3: Pod Security Admission (PSA)

## 1. Tổng quan về Pod Security Admission (PSA)
Trong các phiên bản cũ của Kubernetes, việc giới hạn quyền bảo mật của Pod được thực hiện thông qua **PodSecurityPolicy (PSP)**. Tuy nhiên, do PSP quá phức tạp và thiếu tính linh hoạt, nó đã chính thức bị **loại bỏ (deprecated)** kể từ bản Kubernetes v1.21 và **xóa hoàn toàn** từ v1.25.

Để thay thế, Kubernetes giới thiệu **Pod Security Admission (PSA)**. PSA là một admission controller được tích hợp sẵn (built-in), giúp kiểm soát mức độ bảo mật của Pod dễ dàng hơn thông qua việc dán nhãn (label) trực tiếp lên các **Namespace**. 

PSA hoạt động dựa trên các tiêu chuẩn bảo mật gọi là **Pod Security Standards (PSS)**.

## 2. Pod Security Standards (PSS) - Các cấp độ bảo mật
PSS định nghĩa 3 cấp độ bảo mật (Profiles) từ lỏng lẻo nhất đến khắt khe nhất:

1. **Privileged (Đặc quyền)**:
   - **Mục đích**: Hoàn toàn mở, không hạn chế quyền gì.
   - **Đặc điểm**: Cho phép Pod truy cập sâu vào hệ điều hành của Node (ví dụ: quyền root, hostNetwork, hostPath, privileged mode).
   - **Sử dụng khi**: Chạy các Agent hệ thống, CNI plugin, CSI driver hoặc các công cụ giám sát cấp thấp (monitoring daemon).

2. **Baseline (Cơ bản)**:
   - **Mục đích**: Chặn các lỗ hổng bảo mật phổ biến nhất trong khi vẫn giữ nguyên tính tương thích cho phần lớn các ứng dụng thông thường.
   - **Đặc điểm**: Chặn Pod chạy ở chế độ `privileged`, cấm chia sẻ host network/PID/IPC namespaces, hạn chế việc mount các hostPath nguy hiểm, v.v.
   - **Sử dụng khi**: Mặc định cho hầu hết các ứng dụng thông thường không yêu cầu đặc quyền quá mức.

3. **Restricted (Khắt khe)**:
   - **Mục đích**: Khóa chặt bảo mật theo đúng chuẩn Best Practices.
   - **Đặc điểm**: Bao gồm tất cả các giới hạn của Baseline, kèm theo:
     - Bắt buộc Pod không được chạy dưới quyền root (`runAsNonRoot: true`).
     - Yêu cầu cấu hình seccomp profile an toàn.
     - Phải drop các capabilities của Linux (chỉ cấp đúng quyền cần thiết).
   - **Sử dụng khi**: Các ứng dụng xử lý dữ liệu nhạy cảm, hệ thống tài chính, hoặc môi trường Zero-Trust.

## 3. Các chế độ hoạt động (Modes)
PSA cho phép áp dụng các Profile trên theo 3 chế độ (Modes) độc lập:

- **Enforce**: Hành động mạnh tay nhất. Nếu một Pod được tạo ra vi phạm Profile đã định, PSA sẽ **từ chối (reject)** không cho Pod đó khởi tạo.
- **Audit**: Pod vẫn được tạo ra bình thường, nhưng một bản ghi cảnh báo (audit event) sẽ được gửi vào hệ thống Audit Log của Kubernetes. (Dùng để phân tích sau sự cố).
- **Warn**: Pod vẫn được tạo ra bình thường, nhưng PSA sẽ trả về một thông báo cảnh báo (warning message) trực tiếp ra màn hình terminal của người dùng ngay lúc họ gõ lệnh `kubectl apply`.

*Lưu ý: Ta có thể cấu hình kết hợp nhiều chế độ trên cùng một Namespace. Ví dụ: Chặn (enforce) theo chuẩn Baseline, nhưng cảnh báo (warn) nếu vi phạm chuẩn Restricted.*

## 4. Cách cấu hình PSA
Việc cấu hình PSA cực kỳ đơn giản: Chỉ cần gắn Label vào Namespace theo cú pháp:
`pod-security.kubernetes.io/<MODE>: <PROFILE>`

**Ví dụ:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ns-restricted
  labels:
    # Áp dụng chuẩn "restricted", vi phạm là CHẶN ngay
    pod-security.kubernetes.io/enforce: restricted
    
    # Cảnh báo cho chuẩn "restricted" (nếu có update version mới)
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
```

## 5. Tại sao DevOps cần quan tâm đến PSA?
- Việc chạy container bằng quyền root (mặc định của Docker/K8s) chứa rủi ro rất lớn. Nếu hacker chiếm được quyền điều khiển container, chúng có thể "vượt rào" (Container Breakout) ra ngoài Node vật lý.
- PSA giúp đội ngũ DevOps thiết lập một lớp phòng thủ tự động. Các Developer không thể tự ý đẩy một Pod độc hại hoặc chạy quyền root bừa bãi vào môi trường Production. Mọi thứ phải tuân thủ chuẩn `baseline` hoặc `restricted` tùy theo chính sách.
