# Ghi chú: MLOps - Canary Deployment & Load Testing

## 1. Canary Deployment là gì?
- **Định nghĩa**: Canary Deployment là chiến lược triển khai phần mềm (hoặc mô hình ML), trong đó phiên bản mới (Canary) được phát hành cho một nhóm nhỏ người dùng, trước khi triển khai toàn bộ cho 100% người dùng.
- **Mục đích**: 
  - Giảm thiểu rủi ro: Nếu phiên bản mới có lỗi, chỉ một lượng nhỏ request bị ảnh hưởng.
  - Thử nghiệm trên traffic thực tế (A/B Testing, đánh giá độ ổn định).
- **Hạn chế của KServe RawDeployment**: Trong KServe, chế độ Serverless (dùng Knative) quản lý Canary hoàn hảo. Tuy nhiên, nếu dùng chế độ **RawDeployment** nhẹ nhàng mà không cài đặt Istio hay Gateway API, việc cấu hình `canaryTrafficPercent` sẽ không hoạt động đúng ý (do Kubernetes Service mặc định chỉ hỗ trợ chia tải Round-Robin). 
- **Giải pháp thực tế**: Ở lớp Ingress, ta có thể dùng các Controller như **Traefik**, **Nginx Ingress** hoặc **Istio** để thực hiện **Weighted Routing** (Định tuyến theo trọng số). Ta chạy song song 2 Deployment và chia tải ở lớp Ingress (ví dụ `weight: 9` cho v1 và `weight: 1` cho v2).

## 2. Load Testing (Kiểm thử tải)
- **Định nghĩa**: Quá trình đo lường hiệu năng của hệ thống dưới áp lực lớn để tìm ra giới hạn và đảm bảo hệ thống có thể scale.
- **Các chỉ số quan trọng**:
  - **RPS (Requests Per Second)**: Tốc độ xử lý request trong 1 giây.
  - **Latency**: Độ trễ (thời gian phản hồi).
  - **P95 / P99 Latency**: 95% hoặc 99% số request có độ trễ nhỏ hơn hoặc bằng mức này (chỉ số quan trọng nhất về UX).
- **Công cụ Vegeta**:
  - Công cụ Load Testing HTTP viết bằng Go, cực kỳ nhẹ và nhanh.
  - Điều khiển bằng CLI, có thể xuất báo cáo dạng text hoặc biểu đồ HTML. Rất phù hợp chạy trong môi trường CI/CD.
