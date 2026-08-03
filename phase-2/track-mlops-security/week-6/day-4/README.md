# Task Submission Template

## Task: `Security - OPA Gatekeeper`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 6 / Day 4`
- **Branch**: `phase-2/week-6`
- **Submitted at**: `2026-07-25 23:00` (timezone +07)
- **Time spent**: ``

## 1. Mục tiêu
- Cài đặt OPA Gatekeeper trên Kubernetes Cluster.
- Nắm vững kiến trúc Policy as Code thông qua ConstraintTemplate và Constraint.
- Phát triển policy bằng ngôn ngữ Rego để từ chối image sử dụng tag `:latest`.
- Khai thác Gatekeeper Library để ngăn chặn Pod chạy quyền Privileged và bắt buộc `runAsNonRoot`.

## 2. Các bước thực hiện

**Bước 1: Khởi tạo Cluster mới & Cài đặt Gatekeeper**
- Do Gatekeeper can thiệp sâu vào API Server, một cụm k3d độc lập sẽ được khởi tạo để duy trì tính toàn vẹn cho môi trường:
  ```bash
  k3d cluster create security-lab --agents 1
  ```
- Cài đặt OPA Gatekeeper (v3.16.0) bằng tài liệu cấu hình YAML chính thức:
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.0/deploy/gatekeeper.yaml
  ```
- Theo dõi cho đến khi tất cả các Pod của Gatekeeper trong namespace `gatekeeper-system` đạt trạng thái `Running`:
  ```bash
  kubectl get pods -n gatekeeper-system -w
  ```

**Bước 2: Phát triển Custom Policy cấm tag `:latest`**
- Việc sử dụng tag `:latest` mang lại rủi ro trong kiểm soát phiên bản image.
- Áp dụng file `ConstraintTemplate` (chứa mã nguồn logic Rego):
  ```bash
  kubectl apply -f template-block-latest.yaml
  ```
- Áp dụng file `Constraint` để kích hoạt policy đối với Pod:
  ```bash
  kubectl apply -f constraint-block-latest.yaml
  ```
- Chờ hệ thống đồng bộ policy, sau đó triển khai một Pod sử dụng tag `:latest` (`bad-pod-latest.yaml`):
  ```bash
  kubectl apply -f bad-pod-latest.yaml
  ```
  *(Kết quả: Request sẽ bị Gatekeeper Webhook từ chối với thông báo: `Container <nginx> uses a forbidden :latest tag`).*

**Bước 3: Sử dụng Gatekeeper Library (Ngăn chặn Privileged & NonRoot)**
- Thay vì tự phát triển mã Rego, các policy tiêu chuẩn có thể được tái sử dụng từ thư viện cộng đồng.
- Cài đặt Template từ chối Privileged Pod:
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/pod-security-policy/privileged-containers/template.yaml
  ```
- Áp dụng Constraint từ chối Privileged trên toàn Cluster (ngoại trừ namespace `kube-system` và `gatekeeper-system`):
  ```bash
  cat <<EOF | kubectl apply -f -
  apiVersion: constraints.gatekeeper.sh/v1beta1
  kind: K8sPSPPrivilegedContainer
  metadata:
    name: psp-privileged-container
  spec:
    match:
      kinds:
        - apiGroups: [""]
          kinds: ["Pod"]
      excludedNamespaces: ["kube-system", "gatekeeper-system"]
  EOF
  ```
- Khởi tạo một Pod yêu cầu quyền Privileged:
  ```bash
  kubectl run bad-hacker --image=alpine --privileged -- sleep 9999
  ```
  *(Kết quả: Quá trình khởi tạo bị từ chối với thông báo: `Privileged container is not allowed...`).*

**Bước 4: Dọn dẹp tài nguyên**
- Xóa cụm k3d sau khi hoàn thành bài Lab:
  ```bash
  k3d cluster delete security-lab
  ```

## 3. Kết quả
*(Bổ sung ảnh screenshot terminal quá trình Gatekeeper từ chối `bad-pod-latest.yaml` và lệnh `kubectl run bad-hacker`)*

## 4. Khó khăn & cách giải quyết
- **Khó khăn**: OPA Gatekeeper cung cấp khả năng quản lý linh hoạt hơn PSA (Pod Security Admission), tuy nhiên việc làm quen với ngôn ngữ Rego để viết ConstraintTemplate tạo ra rào cản kỹ thuật.
- **Cách giải quyết**: Khuyến nghị sử dụng [Gatekeeper Library](https://github.com/open-policy-agent/gatekeeper-library) cho các trường hợp phổ biến. Hầu hết các chính sách bảo mật tiêu chuẩn (ngăn chặn HostNetwork, giới hạn Resource Limits) đều đã được đóng gói dưới dạng template, chỉ cần phát triển custom template khi có yêu cầu đặc thù.

## 5. Reference
- [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/)
- [Gatekeeper Library GitHub](https://github.com/open-policy-agent/gatekeeper-library)

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
