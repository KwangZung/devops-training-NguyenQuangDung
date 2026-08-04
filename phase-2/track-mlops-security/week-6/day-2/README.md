# Task Submission Template

## Task: `MLOps - Canary Deployment & Load Testing`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 6 / Day 2`
- **Branch**: `phase-2/week-6`
- **Submitted at**: `2026-07-23 23:00` (timezone +07)
- **Time spent**: `6h`

## 1. Mục tiêu
- Triển khai Canary Deployment cho mô hình với tỷ lệ traffic 90/10 thông qua KServe và Traefik IngressRoute.
- Sử dụng `vegeta` để bắn tải (Load Testing) và phân tích sự phân bổ traffic thực tế vào 2 phiên bản mô hình.

## 2. Quá trình triển khai

*(Quá trình triển khai kế thừa Kubernetes Cluster và namespace `kserve-lab` từ kết quả của Day 1).*

**Bước 1: Chuẩn bị mô hình v2**
- Cấu hình mô hình v2 được chuẩn bị thông qua việc sao chép mô hình đã lưu tại PVC sang một thư mục độc lập mang tên v2.
- Cấu hình file [`data-copier.yaml`](./data-copier.yaml) và áp dụng để khởi động Pod sao chép dữ liệu:
  ```bash
  kubectl apply -f data-copier.yaml
  ```
- Quá trình theo dõi Pod hoàn tất và dọn dẹp tài nguyên:
  ```bash
  kubectl wait --for=condition=ready pod/data-copier -n kserve-lab --timeout=60s
  kubectl delete pod data-copier -n kserve-lab
  ```

**Bước 2: Triển khai 2 phiên bản KServe InferenceService**
- Do chế độ RawDeployment của KServe có những hạn chế về phân bổ traffic theo tỷ lệ, quá trình triển khai cấu hình vận hành 2 InferenceService độc lập và sử dụng Ingress Controller (Traefik) để thực hiện chia tải.
- Các cấu hình phiên bản cũ (nếu có) đã được xóa bỏ:
  ```bash
  kubectl delete inferenceservice iris-model -n kserve-lab --ignore-not-found
  ```
- Các file cấu hình [`iris-model-v1.yaml`](./iris-model-v1.yaml) (vận hành bản gốc) và [`iris-model-v2.yaml`](./iris-model-v2.yaml) (vận hành bản v2 từ thư mục `/v2`) đã được chuẩn bị.
- Quá trình áp dụng cấu hình triển khai:
  ```bash
  kubectl apply -f iris-model-v1.yaml
  kubectl apply -f iris-model-v2.yaml
  ```
- Tiến trình theo dõi trạng thái hoạt động đến khi cả 2 mô hình đạt trạng thái READY:
  ```bash
  kubectl wait --for=condition=ready inferenceservice/iris-model-v1 -n kserve-lab --timeout=300s
  ```
**Bước 3: Triển khai NGINX API Gateway (Server-Side Canary)**
- Khởi tạo hệ thống NGINX đóng vai trò API Gateway nhằm xử lý giới hạn Rewrite URL của chế độ RawDeployment. Thành phần này được thiết lập để tiếp nhận toàn bộ request, điều hướng phân bổ traffic theo tỷ lệ 9:1 và Rewrite URL tương ứng với 2 phiên bản mô hình.
- Cấu hình file [`api-gateway.yaml`](./api-gateway.yaml) được xây dựng và áp dụng vào hệ thống:
  ```bash
  kubectl apply -f api-gateway.yaml
  ```
- Theo dõi trạng thái khởi động của tiến trình Nginx:
  ```bash
  kubectl wait --for=condition=ready pod -l app=api-gateway -n kserve-lab --timeout=60s
  ```

**Bước 4: Trỏ IngressRoute vào API Gateway**
- Cấu hình file [`gateway-route.yaml`](./gateway-route.yaml) được áp dụng nhằm điều hướng Traefik chuyển tiếp traffic KServe tới NGINX Gateway.
- Quá trình áp dụng cấu hình:
  ```bash
  kubectl apply -f gateway-route.yaml
  ```

**Bước 5: Cài đặt công cụ Vegeta**
- Quá trình cài đặt công cụ `vegeta` trên môi trường làm việc:
  ```bash
  wget https://github.com/tsenart/vegeta/releases/download/v12.11.1/vegeta_12.11.1_linux_amd64.tar.gz
  tar -zxvf vegeta_12.11.1_linux_amd64.tar.gz
  sudo mv vegeta /usr/local/bin/
  rm vegeta_12.11.1_linux_amd64.tar.gz
  ```

**Bước 6: Load Testing với Vegeta**
- Cấu hình file [`target.txt`](./target.txt) để định nghĩa chi tiết mẫu request đo kiểm:
  ```text
  POST http://localhost:8082/v1/models/iris-model:predict
  Content-Type: application/json
  @../day-1/iris-input.json
  ```
  *(Quá trình tải được hướng thẳng tới cổng LoadBalancer `8082` của k3d).*
- Thực thi kịch bản Load Testing với tốc độ 50 RPS trong thời gian 20 giây (Tổng lượng request 1000):
  ```bash
  vegeta attack -rate=50 -duration=20s -targets=target.txt > results.bin
  ```

**Bước 7: Thống kê kết quả Load Testing**
- Kết quả phân tích báo cáo đo lường độ trễ và tỷ lệ phản hồi thành công:
  ```bash
  vegeta report results.bin
  ```
  ![report](./screenshots/vegeta-report.png)
- Kết quả thống kê thông tin log từ 2 bản deployment (v1 và v2) để đối soát tỷ lệ chia tải 9:1 của NGINX Gateway (Server-Side Canary):
  ```bash
  echo "--- Số request vào v1 ---"
  kubectl logs deployment/iris-model-v1-predictor -n kserve-lab --tail=5000 | grep "uvicorn.access" | wc -l
  
  echo "--- Số request vào v2---"
  kubectl logs deployment/iris-model-v2-predictor -n kserve-lab --tail=5000 | grep "uvicorn.access" | wc -l
  ```
  ![requests](./screenshots/number-requests-v1-v2.png)

**Bước 8: Dọn dẹp tài nguyên**
- Tiến hành xóa các tài nguyên được khởi tạo trong phần này (bao gồm Pod, Service) và **DUY TRÌ** cluster k3d `kserve-lab` cho giai đoạn tiếp theo:
  ```bash
  kubectl delete inferenceservice iris-model-v1 iris-model-v2 -n kserve-lab
  kubectl delete -f api-gateway.yaml
  kubectl delete -f gateway-route.yaml
  ```

## 3. Kết quả

## 4. Khó khăn & cách giải quyết
- **Khó khăn**: Chế độ `RawDeployment` (không có Istio/Knative) của KServe gặp giới hạn khi dùng tính năng `canaryTrafficPercent`. Hơn nữa, KServe chặn không cho phép ghi đè trường `name` của model bên trong Predictor. Điều này dẫn đến việc không thể dùng Traefik IngressRoute để ép 2 model (v1 và v2) dùng chung 1 URL `/v1/models/iris-model:predict` (KServe sẽ báo 404).
- **Cách giải quyết**: Triển khai giải pháp **NGINX API Gateway** trung gian. Cấu hình Nginx tiếp nhận toàn bộ request chung tại `/v1/models/iris-model:predict`, áp dụng module `split_clients` để tự động phân bổ traffic tỷ lệ 90/10. Tiếp theo, hệ thống thực hiện **Rewrite URL** và `proxy_pass` đến các phiên bản KServe v1 và v2 tương ứng. Giải pháp này đáp ứng nguyên lý kỹ thuật Server-Side Canary Routing.

## 5. Reference
- [Vegeta GitHub](https://github.com/tsenart/vegeta)
- [Traefik Weighted Routing](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroute)

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Review lại code 1 lượt.
