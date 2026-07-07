# Task Submission Template

> Mỗi task = 1 thư mục con + 1 PR/MR riêng. Copy template này vào `README.md` của task.

## Task: `Week 3: Kubernetes Deep Dive`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 3 / Day 2`
- **Branch**: `phase-2/week-3-kubernetes`
- **Submitted at**: `2026-07-07 12:09` (timezone +07)
- **Time spent**: `6h`

## 1. Mục tiêu
### Day 1 - k8s architecture, kubectl, install k3d, deploy first pod
- Cài đặt các công cụ quản trị (kubectl, k3d) trên Terminal.
- Khởi tạo Cluster cục bộ bằng k3d.
- Triển khai Pod đầu tiên và thiết lập mạng nội bộ qua Port thông qua Service.

### Day 2 - Deployment, Service, Ingress
- Triển khai ứng dụng nhiều bản sao và cấu hình nâng cấp tự động không gián đoạn bằng Deployment.
- Điều hướng và phân giải tên miền ảo nội bộ thông qua Ingress và Service.

## 2. Cách chạy
### Day 1 - k8s architecture, kubectl, install k3d, deploy first pod
```bash
# 1. Cài đặt kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# 2. Cài đặt k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d --version

# 3. Khởi tạo Cluster
k3d cluster create dev --agents 2 -p "8080:80@loadbalancer" --image rancher/k3s:v1.30.3-k3s1
kubectl get nodes

# 4. Triển khai Pod và Service
kubectl run web --image=nginx --port=80
kubectl expose pod web --type=ClusterIP
kubectl get pods,svc
```

### Day 2: Deployment, Service, Ingress
Thay vì gõ từng lệnh thủ công (Imperative), toàn bộ quy trình thực hành đã được chuẩn hóa theo tài liệu gốc của Kubernetes (Khai báo YAML - Declarative) và đóng gói vào các Bash Script. Chỉ cần chạy các tệp tin này để tự động hóa toàn bộ quá trình khởi tạo cấu hình và áp dụng vào Cluster:

```bash
# 1. Cấp quyền thực thi cho các tệp lệnh
chmod +x deployment.sh service.sh ingress.sh

# 2. Deployment (Khởi tạo, Rolling Update và Rollback)
./deployment.sh

# 3. Service (Thiết lập mạng nội bộ liên kết các Pod)
./service.sh

# 4. Ingress (Tạo quy tắc định tuyến mạng)
./ingress.sh
```

## 3. Kết quả
### Day 1 - k8s architecture, kubectl, install k3d, deploy first pod
- Đã cài đặt thành công kubectl và k3d trên hệ thống.
- Cluster `dev` đã hoạt động, tất cả các Node đều đạt trạng thái Ready.
- Pod `web` được kéo Image Nginx và đang chạy (Running).
- Service `web` đã cấp phát địa chỉ ClusterIP thành công để mở Port 80.

![Cài đặt công cụ](./screenshots/day1-kubectl-k3d-version.png)
![Khởi tạo Cluster & Triển khai Pod](./screenshots/day-1-kubectl-get-nodes-get-pods-svc.png)

### Day 2 - Deployment, Service, Ingress
- Chạy thành công quy trình Rolling Update và Rollback an toàn trên Deployment.
- Ingress đã kết nối thành công tên miền ảo `app.local` vào Service bên trong Cluster. Lệnh `curl` đã trả về thành công mã HTML mặc định của Nginx qua HTTP.
- Cấu hình thành công TLS Termination trên Ingress sử dụng chứng chỉ tự sinh (Self-signed), đảm bảo truy cập HTTPS an toàn.

![Tạo Deployment](./screenshots/day-2-get-pods-after-create-3-demo-app.png)
![Quản lý Deployment](./screenshots/day-2-rollout-status.png)
![Kiểm thử Ingress](./screenshots/day-2-tee-hosts-curl.png)
![TLS Termination](./screenshots/day-2-tls-termination.png)

## 4. Khó khăn & cách giải quyết
### Day 1 - k8s architecture, kubectl, install k3d, deploy first pod
- **Lỗi sập Server node (Closing database connections)**: Lệnh tạo Cluster bị kẹt ở `Starting agents...` và `kubectl` liên tục báo lỗi `connection refused`.
  - *Cách fix*: Nguyên nhân do bản image tự kéo mặc định (`v1.35.5-k3s1`) gặp trục trặc nội bộ. Khắc phục bằng cách xóa Cluster hỏng (`k3d cluster delete dev`) và ép k3d dùng bản ổn định bằng cờ `--image rancher/k3s:v1.30.3-k3s1`.
- **Lỗi đụng độ Port (port is already allocated)**: Docker không thể khởi tạo loadbalancer vì port 8080 trên máy đã bị chiếm dụng.
  - *Cách fix*: Dùng lệnh `docker ps` để dò tìm mã ID của Container rác đang chạy ngầm trên port 8080, sau đó tiêu diệt nó bằng `docker rm -f <Container-ID>` để giải phóng hoàn toàn port này.

### Day 2 - Deployment, Service, Ingress
- **Lỗi Pending toàn bộ Pod (Disk Pressure)**: Kubelet từ chối lên lịch cho Pod do ổ cứng máy ảo (Ubuntu LVM) chỉ được cấp mặc định 20GB và đã bị đầy (Use% > 85%). Kubelet áp dụng taint cấm `disk-pressure`.
  - *Cách fix*: Mở rộng phân vùng LVM trên Ubuntu để chiếm trọn phần dung lượng ảo chưa được dùng bằng các lệnh `sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv` và `sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv`. Đồng thời kết hợp dọn rác bằng `docker system prune -a --volumes -f`.

## 5. Reference
- Kubernetes Components Architecture: https://kubernetes.io/docs/concepts/overview/components/
- K3d Official Documentation: https://k3d.io/
- Kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- Bài giảng và tài liệu nội bộ khóa DevSecOps Training.

## 6. Self-check
- [ ] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [ ] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [ ] Đã review lại code 1 lượt.