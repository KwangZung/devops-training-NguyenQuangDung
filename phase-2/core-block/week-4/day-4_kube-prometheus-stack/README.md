# Hướng dẫn và Báo cáo Thực hành Day 4: kube-prometheus-stack

Tài liệu này chứa hướng dẫn chi tiết các bước thực hành giám sát và thu thập log trong Kubernetes Cluster bằng Helm, đồng thời là mẫu báo cáo nộp bài của Day 4.

## Thông tin nộp bài

- **Intern**: Nguyễn Quang Dũng
- **Phase / Week / Day**: Phase 2 / Week 4 / Day 4
- **Branch**: `phase-2/week-4/day-4_kube-prometheus-stack`
- **Submitted at**: [Điền ngày giờ nộp bài]
- **Time spent**: [Điền thời gian thực hiện]

---

## Mục tiêu bài thực hành

- Cài đặt thành công kube-prometheus-stack và Loki trên Kubernetes Cluster bằng Helm.
- Cấu hình expose giao diện Grafana ra ngoài thông qua Ingress.
- Import thành công Dashboard ID 1860 phục vụ việc giám sát tài nguyên Node.
- Thiết lập luật cảnh báo PrometheusRule phát hiện Pod restart nhiều lần.
- Kiểm tra tính đúng đắn của cảnh báo bằng cách giả lập sự cố.

---

## Hướng dẫn các bước thực hiện

### Bước 1: Chuẩn bị môi trường và Helm

Ta cần đảm bảo đã chạy cụm Kubernetes local (như Minikube hoặc Kind) và cài đặt sẵn công cụ Helm.

1. Khởi động cụm Kubernetes. Nếu dùng Minikube, ta cần bật tính năng Ingress:
   ```bash
   minikube start
   minikube addons enable ingress
   ```
2. Thêm các Helm repositories cần thiết và cập nhật:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo add grafana https://grafana.github.io/helm-charts
   helm repo update
   ```

### Bước 2: Cấu hình và Cài đặt kube-prometheus-stack

Để dễ dàng quản lý cấu hình Grafana và các thành phần khác, ta sẽ tạo một file cấu hình custom values.

1. Tạo file `values.yaml` với nội dung cơ bản để cấu hình Grafana admin password và tự động import Dashboard:
   ```yaml
   grafana:
     adminPassword: "admin"
     ingress:
       enabled: true
       hosts:
         - grafana.local
   ```
2. Tạo Namespace riêng cho việc monitoring:
   ```bash
   kubectl create namespace monitoring
   ```
3. Cài đặt kube-prometheus-stack bằng Helm sử dụng file values vừa tạo:
   ```bash
   helm install prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
   ```

### Bước 3: Cài đặt Loki và Agent thu thập Log

Ta sẽ cài đặt Loki làm hệ thống quản lý log tập trung cùng Promtail (hoặc Grafana Alloy) để gửi log từ các container tới Loki.

1. Cài đặt Loki bằng Helm:
   ```bash
   helm install loki grafana/loki-simple-scalable -n monitoring
   ```
2. Cài đặt Promtail để thu thập log từ các Node và container gửi về Loki:
   ```bash
   helm install promtail grafana/promtail --set config.clients[0].url=http://loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push -n monitoring
   ```
3. Cấu hình Data Source Loki trên giao diện Grafana sau khi cài đặt thành công.

### Bước 4: Expose Grafana qua Ingress và Kiểm tra

1. Để truy cập Grafana qua tên miền `grafana.local`, ta cần trỏ tên miền này về IP của Ingress Controller.
   - Lấy IP của Ingress:
     ```bash
     kubectl get ingress -n monitoring
     ```
   - Thêm dòng cấu hình vào file hosts trên máy (nếu chạy Windows, chỉnh sửa file `C:\Windows\System32\drivers\etc\hosts` bằng quyền Administrator):
     ```text
     <IP_CUA_INGRESS> grafana.local
     ```
2. Truy cập địa chỉ `http://grafana.local` trên trình duyệt để kiểm tra giao diện Grafana. Đăng nhập bằng tài khoản `admin` và mật khẩu đã cấu hình trong file `values.yaml`.

### Bước 5: Import Dashboard và Kiểm tra Metrics

1. Trong giao diện Grafana, truy cập Dashboards -> New -> Import.
2. Nhập ID `1860` (Node Exporter Full) và chọn Data Source là Prometheus.
3. Kiểm tra xem các biểu đồ về CPU, RAM, Disk của các Node đã hiển thị dữ liệu đầy đủ chưa.

### Bước 6: Tạo PrometheusRule cảnh báo Pod restart nhiều lần

Ta sẽ tạo một cảnh báo tự động phát hiện nếu có một container trong Pod bị restart quá 3 lần trong vòng 10 phút.

1. Tạo file `alert-rules.yaml` với nội dung khai báo tài nguyên Custom Resource `PrometheusRule`:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: PrometheusRule
   metadata:
     name: pod-restart-alert
     namespace: monitoring
     labels:
       release: prometheus-stack
   spec:
     groups:
     - name: pod-alerts
       rules:
       - alert: PodRestartTooMany
         expr: increase(kube_pod_container_status_restarts_total[10m]) > 3
         for: 1m
         labels:
           severity: warning
         annotations:
           summary: "Pod {{ $labels.pod }} container {{ $labels.container }} restarted too many times"
           description: "Container has restarted {{ $value }} times within the last 10 minutes."
   ```
2. Apply file cấu hình trên vào cụm Kubernetes:
   ```bash
   kubectl apply -f alert-rules.yaml
   ```
3. Truy cập vào giao diện Prometheus (hoặc mục Alerts trên Grafana) để kiểm tra xem rule mới đã được nạp thành công chưa.

### Bước 7: Kiểm tra cảnh báo bằng cách giả lập sự cố

Ta sẽ tạo một Pod bị lỗi liên tục để kích hoạt cảnh báo hoạt động.

1. Tạo file `crash-pod.yaml` chạy một container liên tục exit để tạo trạng thái CrashLoopBackOff:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: crash-pod
     namespace: default
   spec:
     containers:
     - name: crash-container
       image: busybox
       command: ["/bin/sh", "-c", "exit 1"]
   ```
2. Deploy Pod này:
   ```bash
   kubectl apply -f crash-pod.yaml
   ```
3. Chờ khoảng 5-10 phút để container bị restart nhiều hơn 3 lần. Theo dõi trạng thái restart của Pod qua lệnh:
   ```bash
   kubectl get pods -w
   ```
4. Kiểm tra trên giao diện Alerts của Prometheus hoặc Alertmanager để xác nhận cảnh báo `PodRestartTooMany` đã chuyển sang trạng thái firing. Chụp ảnh màn hình làm báo cáo.

---

## Báo cáo Kết quả Thực hành của bệ hạ

*Bệ hạ vui lòng cập nhật kết quả thực hiện vào các mục dưới đây sau khi hoàn thành các bước.*

### 1. Kết quả Cài đặt Stack
- Lệnh chạy thực tế:
- Ảnh chụp danh sách các Pod đang chạy trong namespace `monitoring` (sử dụng lệnh `kubectl get pods -n monitoring`):

### 2. Cấu hình Ingress và Expose Grafana
- Nội dung file Ingress YAML hoặc phần cấu hình Ingress trong values.yaml:
- Ảnh chụp màn hình đăng nhập thành công vào Grafana qua tên miền `grafana.local`:

### 3. Trực quan hóa dữ liệu (Dashboard)
- Ảnh chụp màn hình Dashboard ID `1860` (Node Exporter Full) hiển thị đầy đủ thông số của cụm Kubernetes:
- Ảnh chụp màn hình giao diện Explore trong Grafana truy vấn thành công log từ Loki:

### 4. Cảnh báo PrometheusRule & Giả lập sự cố
- Lệnh apply rule cảnh báo:
- Ảnh chụp danh sách các rule cảnh báo trên giao diện Prometheus/Grafana cho thấy rule `PodRestartTooMany` đã được nhận diện:
- Ảnh chụp màn hình giao diện Alertmanager hoặc Grafana cho thấy cảnh báo `PodRestartTooMany` đang ở trạng thái firing khi giả lập Pod bị lỗi:

### 5. Khó khăn gặp phải và Cách giải quyết
- *Mô tả các lỗi gặp phải trong quá trình cài đặt, expose Ingress hoặc cấu hình Loki và cách bệ hạ xử lý.*