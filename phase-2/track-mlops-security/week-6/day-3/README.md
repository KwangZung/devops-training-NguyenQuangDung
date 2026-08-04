# Task Submission Template

## Task: `Security - Pod Security Admission (PSA)`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 6 / Day 3`
- **Branch**: `phase-2/week-6`
- **Submitted at**: `2026-07-24 23:00` (timezone +07)
- **Time spent**: ``

## 1. Mục tiêu
- Nắm vững kiến thức và áp dụng Pod Security Admission (PSA) trên Kubernetes Cluster.
- Cấu hình các Namespace với các tiêu chuẩn bảo mật baseline và restricted.
- Kiểm tra hành vi của PSA khi enforce các Pod vi phạm chính sách bảo mật (như chạy quyền root, chạy privileged mode).

## 2. Các bước thực hiện

*(Lưu ý: Bài Lab này sử dụng lại cluster k3d tên `kserve-lab` từ Day 1 & 2. Cụm k3d này đã được khởi tạo bằng lệnh `k3d cluster create kserve-lab --agents 1`).*

**Bước 1: Tạo Namespace và gán nhãn PSA**
- Tiến hành tạo 2 Namespace riêng biệt để cấu hình các chuẩn bảo mật khác nhau:
  ```bash
  kubectl create namespace ns-baseline
  kubectl create namespace ns-restricted
  ```
- Gán label để kích hoạt PSA trên 2 Namespace này ở mode enforce và warn.
- Cấu hình được áp dụng cho Namespace `ns-baseline`:
  ```bash
  kubectl label --overwrite ns ns-baseline pod-security.kubernetes.io/enforce=baseline
  kubectl label --overwrite ns ns-baseline pod-security.kubernetes.io/warn=baseline
  ```
- Cấu hình được áp dụng cho Namespace `ns-restricted`:
  ```bash
  kubectl label --overwrite ns ns-restricted pod-security.kubernetes.io/enforce=restricted
  kubectl label --overwrite ns ns-restricted pod-security.kubernetes.io/warn=restricted
  ```

**Bước 2: Kiểm tra chuẩn Baseline**
- Chuẩn Baseline hạn chế các quyền hệ thống có rủi ro cao (như privileged) nhưng vẫn đảm bảo ứng dụng vận hành bình thường.
- Tiến hành tạo file `pod-nginx-normal.yaml`:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: nginx-normal
    namespace: ns-baseline
  spec:
    containers:
    - name: nginx
      image: nginx:alpine
  ```
- Áp dụng cấu hình Pod vào `ns-baseline`:
  ```bash
  kubectl apply -f pod-nginx-normal.yaml
  ```
  *(Pod sẽ được khởi tạo thành công do container Nginx thông thường đáp ứng chuẩn baseline).*

- Tạo file `pod-privileged.yaml` với cấu hình yêu cầu đặc quyền hệ thống:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: bad-pod
    namespace: ns-baseline
  spec:
    containers:
    - name: alpine
      image: alpine
      command: ["sleep", "9999"]
      securityContext:
        privileged: true
  ```
- Áp dụng cấu hình vào `ns-baseline`:
  ```bash
  kubectl apply -f pod-privileged.yaml
  ```
  *(Quá trình khởi tạo sẽ bị từ chối từ API Server với thông báo Error: `pods "bad-pod" is forbidden: violates PodSecurity "baseline"... Privileged containers are not allowed`).*

**Bước 3: Kiểm tra chuẩn Restricted**
- Chuẩn Restricted yêu cầu các ràng buộc khắt khe, bao gồm việc Pod không được chạy dưới quyền Root.
- Thử áp dụng cấu hình Nginx thông thường (chạy quyền Root mặc định) vào `ns-restricted`:
  ```bash
  sed 's/namespace: ns-baseline/namespace: ns-restricted/' pod-nginx-normal.yaml | kubectl apply -f -
  ```
  *(Pod Nginx sẽ bị từ chối do vi phạm chuẩn restricted: "must not run as root", "seccompProfile").*

- Để Pod vận hành được trong `ns-restricted`, cấu hình SecurityContext an toàn là bắt buộc. Tiến hành tạo file `pod-secure.yaml`:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: secure-pod
    namespace: ns-restricted
  spec:
    securityContext:
      runAsNonRoot: true
      seccompProfile:
        type: RuntimeDefault
    containers:
    - name: alpine
      image: alpine
      command: ["sleep", "9999"]
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
  ```
- Áp dụng cấu hình Pod:
  ```bash
  kubectl apply -f pod-secure.yaml
  ```
  *(Pod được khởi tạo thành công do tuân thủ các quy tắc bảo mật khắt khe nhất).*

**Bước 4: Dọn dẹp tài nguyên**
- Xóa 2 Namespace đã tạo (các Pod bên trong sẽ tự động bị xóa):
  ```bash
  kubectl delete namespace ns-baseline ns-restricted
  rm pod-nginx-normal.yaml pod-privileged.yaml pod-secure.yaml
  ```

## 3. Kết quả
*(Ảnh screenshot terminal hiển thị quá trình báo lỗi `is forbidden: violates PodSecurity` khi triển khai các Pod vi phạm)*

## 4. Khó khăn & cách giải quyết
- **Khó khăn**: Việc quản lý quyền của Pod bằng PodSecurityPolicy (PSP) đã không còn khả dụng trên các phiên bản Kubernetes mới. Việc thiết lập OPA Gatekeeper policy để thay thế cho các rule cơ bản đòi hỏi chi phí vận hành cao.
- **Cách giải quyết**: Triển khai giải pháp PSA (Pod Security Admission) được tích hợp sẵn. Cấu hình Label trên Namespace cho phép khoanh vùng bảo mật hiệu quả, ngăn chặn việc thực thi Container bằng quyền Root trên môi trường Production.

## 5. Reference
- [Kubernetes Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Review lại code 1 lượt.
