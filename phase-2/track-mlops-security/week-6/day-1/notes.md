# Lý thuyết Week 6 - Model Serving & Kubernetes Hardening

## Day 1: MLOps - Model Serving với KServe

### Tổng quan về KServe

KServe (trước đây gọi là KFServing) là một nền tảng Cloud Native chuyên biệt cho việc phục vụ suy luận mô hình AI/ML trên Kubernetes. KServe thuộc hệ sinh thái CNCF (dự án Incubating), cung cấp giao diện chuẩn hóa và có khả năng mở rộng cao cho các tác vụ Predictive AI lẫn Generative AI (LLM).

Mục tiêu thiết kế chính của KServe bao gồm:
- Chuẩn hóa API: Cung cấp giao thức Open Inference Protocol (V1 và V2) giúp thống nhất cách giao tiếp giữa Client và các mô hình ML khác nhau.
- Tối ưu tài nguyên: Hỗ trợ cơ chế tự động mở rộng (Autoscaling), bao gồm Scale-to-Zero giúp tiết kiệm chi phí tính toán và GPU.
- Đơn giản hóa trải nghiệm: Che giấu sự phức tạp của Kubernetes bên dưới bằng cách cung cấp các Custom Resource Definition (CRD) cấp cao.

### Kiến trúc của KServe

Kiến trúc KServe được chia làm hai phần tách biệt: Control Plane và Data Plane.

**Control Plane** chịu trách nhiệm quản lý vòng đời và cấu hình của các mô hình triển khai thông qua CRD. KServe Operator giám sát các khai báo CRD và tự động khởi tạo các tài nguyên Kubernetes tương ứng (Deployment, Service, Knative Service, Ingress Route). Luồng hoạt động cụ thể:
1. Người dùng áp dụng một manifest InferenceService vào Kubernetes Cluster.
2. KServe Controller (Operator) nhận biết tài nguyên mới thông qua cơ chế Watch.
3. KServe Mutating Webhook inject thêm Storage Initializer Init Container vào Pod.
4. Controller chuyển đổi InferenceService thành các tài nguyên hạ tầng tùy theo chế độ triển khai:
   - Serverless Mode: Khởi tạo Knative Service (ksvc), cấu hình Knative Revision, Route và Pod Autoscaler (KPA).
   - RawDeployment Mode: Khởi tạo Kubernetes Deployment, Service, HorizontalPodAutoscaler (HPA) và Ingress route.

**Data Plane** chịu trách nhiệm xử lý trực tiếp các request suy luận từ Client. Luồng xử lý:
1. Client gửi HTTP/gRPC request đến Ingress Gateway.
2. Ingress Gateway điều hướng request:
   - Nếu có Transformer: Request đi tới Transformer Container (Pre-process) -> Predictor Container (Dự đoán) -> Transformer (Post-process) -> Client.
   - Nếu không có Transformer: Request đi thẳng vào Predictor Container -> Client.
   - Nếu gửi request giải thích (:explain): Request được chuyển hướng đến Explainer Container.

### Các thành phần chính

**InferenceService (ISVC)** là CRD chính (serving.kserve.io/v1beta1) đại diện cho một mô hình ML được triển khai. Khai báo trạng thái mong muốn của ứng dụng suy luận, bao gồm tối đa 3 thành phần con:
- Predictor (bắt buộc): Chứa mô hình ML và thực thi quá trình suy luận. Nhận dữ liệu đầu vào, thực hiện dự đoán thông qua các ServingRuntime (MLServer, Triton, TorchServe, vLLM...) và trả về kết quả.
- Transformer (tùy chọn): Đóng vai trò tiền xử lý và hậu xử lý. Biến đổi dữ liệu đầu vào thô (hình ảnh, văn bản chưa mã hóa) thành định dạng Tensor tương thích với Predictor.
- Explainer (tùy chọn): Cung cấp khả năng giải thích mô hình. Tích hợp các thuật toán như SHAP, Captum, Alibi để phân tích lý do mô hình đưa ra một dự đoán cụ thể.

**ServingRuntime và ClusterServingRuntime** là CRD định nghĩa môi trường chạy (Runtime Container) cho từng định dạng mô hình. ServingRuntime có phạm vi Namespace, còn ClusterServingRuntime có phạm vi toàn Cluster.

### Các ML Framework được hỗ trợ

KServe hỗ trợ sẵn nhiều ML Framework phổ biến thông qua cơ chế Pluggable ServingRuntimes:

| ML Framework | Serving Runtime | Giao thức |
|---|---|---|
| Scikit-Learn | MLServer / Python Runtime | V1/V2 |
| XGBoost | MLServer / Triton | V1/V2 |
| LightGBM | MLServer | V2 |
| PyTorch | TorchServe / Triton | V1/V2 |
| TensorFlow | TFServing / Triton | V1 / REST/gRPC |
| ONNX | Triton / MLServer | V2 |
| Hugging Face | HuggingFace LLM / MLServer | OpenAI / V2 |
| LLM / GenAI | vLLM / TensorRT-LLM | OpenAI / V2 |

### Serverless Inference với Knative

Khi triển khai ở chế độ Serverless Mode, KServe tích hợp với Knative Serving để mang lại hai tính năng quan trọng:

**Autoscaling theo Request**: Thay vì sử dụng HPA truyền thống dựa trên CPU/Memory, Knative Pod Autoscaler (KPA) mở rộng dựa trên số lượng request đồng thời (Concurrency) hoặc số request mỗi giây (RPS). Điều này phù hợp hơn với các workload suy luận AI vốn có tính chất bùng nổ (burst traffic).

**Scale-to-Zero**: Khi không có request trong một khoảng thời gian nhất định (Grace Period), Knative sẽ giảm số lượng Pod xuống 0 để giải phóng hoàn toàn GPU/CPU, giúp tiết kiệm chi phí hạ tầng đáng kể. Khi có request mới đến, cơ chế Cold Start sẽ kích hoạt:
1. Knative Activator giữ kết nối của request.
2. Knative tín hiệu cho Kubernetes khởi tạo Pod mới.
3. KServe Storage Initializer tải mô hình từ Storage về Pod.
4. Predictor Container khởi động thành công.
5. Knative Activator chuyển tiếp request đang đợi vào Pod để xử lý.

### ModelMesh cho Multi-Model Serving

Triển khai tiêu chuẩn của KServe gán mỗi InferenceService với một Pod riêng biệt. Khi có hàng trăm hoặc hàng ngàn mô hình nhỏ, phương pháp này gây lãng phí tài nguyên. ModelMesh là sub-project giải quyết bài toán Multi-Model Serving với mật độ cao bằng cách:
- Tạo Shared Pod Pool: Các Pod dùng chung chạy sẵn Runtime (Triton hoặc MLServer) cùng Sidecar ModelMesh.
- Nạp/Giải phóng mô hình động: Khi nhận request tới một mô hình cụ thể, ModelMesh nạp mô hình đó vào RAM/VRAM. Các mô hình ít sử dụng bị giải phóng theo cơ chế LRU Eviction.
- Định tuyến thông minh: ModelMesh Router điều hướng request tới đúng Pod đang giữ mô hình cần xử lý trong bộ nhớ.

### Canary Rollout (Traffic Splitting)

KServe hỗ trợ triển khai Canary trực tiếp trên InferenceService trong chế độ Serverless Mode. Thuộc tính canaryTrafficPercent bên trong spec của Predictor được cấu hình như sau:

```yaml
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  name: "sklearn-iris"
spec:
  predictor:
    canaryTrafficPercent: 10
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kserve-examples/models/sklearn/2.0/model"
```

Cơ chế hoạt động:
- KServe tự động ghi nhớ phiên bản ổn định gần nhất nhận 100% traffic (Last Known Good Revision).
- Khi áp dụng manifest mới có canaryTrafficPercent: 10, KServe tạo Revision mới và điều hướng 10% request sang Revision mới, 90% còn lại vẫn đi vào Revision cũ.
- Quá trình Promote (thăng cấp): Tăng giá trị canaryTrafficPercent lên 100 hoặc xóa bỏ trường này.
- Quá trình Rollback: Đặt giá trị canaryTrafficPercent về 0.

### Tùy chọn lưu trữ mô hình (Storage Options)

Khi InferenceService khởi chạy, KServe inject một Init Container tên kserve-storage-initializer. Init Container này đọc trường storageUri, kết nối tới hạ tầng lưu trữ tương ứng, tải trọng số mô hình về folder dùng chung /mnt/models, sau đó kết thúc để Predictor Container chính nạp mô hình.

Các định dạng Storage được hỗ trợ:
- Amazon S3: URI dạng s3://bucket-name/path, xác thực qua IRSA hoặc Kubernetes Secret.
- Google Cloud Storage (GCS): URI dạng gs://bucket-name/path, xác thực qua Service Account Key.
- Azure Blob Storage: URI dạng wasb:// hoặc https://<account>.blob.core.windows.net/.
- Persistent Volume Claim (PVC): URI dạng pvc://<pvc-name>/path, truy cập trực tiếp trên Kubernetes.
- OCI Artifacts (Modelcars): URI dạng oci://registry/repository:tag, mô hình được đóng gói dưới dạng Container Image.
- Hugging Face Hub: URI dạng hf://<org>/<model-name>, nạp trực tiếp từ Hugging Face.
- HTTP/HTTPS: URI http:// hoặc https:// để tải file mô hình qua liên kết web.

### Yêu cầu cài đặt

Để triển khai KServe, hệ thống cần đáp ứng các tiền đề sau:
- Kubernetes Cluster phiên bản 1.26 trở lên (khuyến nghị 1.32+).
- Công cụ CLI: kubectl (với quyền cluster-admin), helm, và git.
- Cert-Manager phiên bản 1.15.0 trở lên (bắt buộc để cấp TLS cho Admission Webhooks).
- Ingress Controller hoặc Gateway API: Istio (khuyến nghị chính thức), Contour, hoặc Gateway API tương thích.
- Knative Serving: Bắt buộc nếu dùng Serverless Mode (Scale-to-zero, Canary). Không bắt buộc với RawDeployment Mode.
