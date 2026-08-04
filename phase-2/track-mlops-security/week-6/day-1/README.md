# Task Submission Template

## Task: `MLOps - Model Serving với KServe`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 6 / Day 1`
- **Branch**: `phase-2/week-6`
- **Submitted at**: `2026-07-22 23:00` (timezone +07)
- **Time spent**: `9h`

## 1. Mục tiêu
- Cài đặt KServe lên Kubernetes Cluster (k3d) ở chế độ RawDeployment.
- Huấn luyện một mô hình Scikit-Learn đơn giản (Iris Classification), lưu file model lên PVC.
- Tạo InferenceService để phục vụ mô hình đó thông qua KServe.
- Gửi request suy luận và nhận kết quả dự đoán thành công.

## 2. Quá trình triển khai

**Bước 1: Khởi tạo Kubernetes Cluster bằng k3d**
- Tiến hành tạo một Cluster k3d có tên `kserve-lab`:
  ```bash
  k3d cluster create kserve-lab --agents 1 -p "8082:80@loadbalancer"
  ```
- Kiểm tra trạng thái Cluster đã sẵn sàng:
  ```bash
  kubectl get nodes
  ```
  ![ready](./screenshots/check-cluster-ready.png)

**Bước 2: Cài đặt KServe (chế độ RawDeployment)**
- Quá trình triển khai sử dụng chế độ RawDeployment để tránh cài đặt Knative và Istio. Chế độ này sử dụng Kubernetes Deployment, Service và HPA thuần túy.
- Tiến hành cài đặt công cụ `kustomize` và `jq` (yêu cầu bắt buộc cho kịch bản cài đặt của KServe):
  ```bash
  sudo apt-get update && sudo apt-get install jq -y
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  sudo mv kustomize /usr/local/bin/
  ```
- Thực hiện clone repository KServe và khởi chạy kịch bản cài đặt:
  ```bash
  git clone https://github.com/kserve/kserve.git
  cd kserve
  ./hack/kserve-install.sh -r --kustomize
  ```
- Theo dõi và chờ đợi KServe Controller chuyển sang trạng thái sẵn sàng:
  ```bash
  kubectl wait --for=condition=ready pod --all -n kserve --timeout=300s
  ```
- Áp dụng cấu hình ClusterServingRuntime mặc định (bắt buộc để vận hành các mô hình sklearn, xgboost...):
  ```bash
  kubectl apply -k config/runtimes
  ```
- Quay trở lại thư mục gốc của ngày 1:
  ```bash
  cd ..
  ```
- Xác nhận trạng thái KServe đã được cài đặt thành công:
  ```bash
  kubectl get pods -n kserve
  ```
  ![kserve](./screenshots/kserve-pods.png)

**Bước 4: Huấn luyện mô hình và lưu lên PVC**
- Khởi tạo Namespace dành riêng cho quá trình triển khai:
  ```bash
  kubectl create namespace kserve-lab
  ```
- Triển khai PersistentVolumeClaim để lưu trữ file model. Các cấu hình được lưu tại file [`pvc.yaml`](./pvc.yaml):
  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: model-storage
    namespace: kserve-lab
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
  ```
  ```bash
  kubectl apply -f pvc.yaml
  ```
- Chuẩn bị file mã nguồn [`train.py`](./train.py) dùng để huấn luyện mô hình Iris Classification và lưu kết quả ra file `model.joblib`:
  ```python
  from sklearn.datasets import load_iris
  from sklearn.ensemble import RandomForestClassifier
  import joblib
  import os

  # Tải dataset Iris
  iris = load_iris()
  X, y = iris.data, iris.target

  # Huấn luyện mô hình
  model = RandomForestClassifier(n_estimators=100, random_state=42)
  model.fit(X, y)

  # Lưu file model
  output_dir = "/mnt/models"
  os.makedirs(output_dir, exist_ok=True)
  model_path = os.path.join(output_dir, "model.joblib")
  joblib.dump(model, model_path)
  print(f"Model saved to {model_path}")
  ```
- Xây dựng file [`train-job.yaml`](./train-job.yaml) nhằm thực thi quá trình huấn luyện dưới dạng Kubernetes Job, thực hiện mount PVC vào `/mnt/models`:
  ```yaml
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: train-iris-model
    namespace: kserve-lab
  spec:
    template:
      spec:
        containers:
          - name: trainer
            image: python:3.9-slim
            command: ["bash", "-c"]
            args:
              - |
                pip install scikit-learn joblib && python /scripts/train.py
            volumeMounts:
              - name: model-volume
                mountPath: /mnt/models
              - name: script-volume
                mountPath: /scripts
        volumes:
          - name: model-volume
            persistentVolumeClaim:
              claimName: model-storage
          - name: script-volume
            configMap:
              name: train-script
        restartPolicy: Never
    backoffLimit: 1
  ```
- Đóng gói nội dung file `train.py` vào ConfigMap và khởi chạy Job:
  ```bash
  kubectl create configmap train-script --from-file=train.py -n kserve-lab
  kubectl apply -f train-job.yaml
  ```
- Chờ tiến trình Job hoàn tất và kiểm tra kết quả:
  ```bash
  kubectl wait --for=condition=complete job/train-iris-model -n kserve-lab --timeout=300s
  kubectl logs job/train-iris-model -n kserve-lab
  ```
    ![train](./screenshots/train-success.png)

**Bước 5: Tạo InferenceService triển khai mô hình**
- Cấu hình file [`inference-service.yaml`](./inference-service.yaml) để đọc model từ PVC và cung cấp dịch vụ phân tích thông qua giao thức V2:
  ```yaml
  apiVersion: "serving.kserve.io/v1beta1"
  kind: "InferenceService"
  metadata:
    name: "iris-model"
    namespace: "kserve-lab"
    annotations:
      serving.kserve.io/deploymentMode: RawDeployment
  spec:
    predictor:
      model:
        modelFormat:
          name: sklearn
        storageUri: "pvc://model-storage"
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
  ```
  ```bash
  kubectl apply -f inference-service.yaml
  ```
- Xác nhận trạng thái InferenceService:
  ```bash
  kubectl get inferenceservice iris-model -n kserve-lab
  ```
- Quá trình chờ đến khi cột READY chuyển sang trạng thái True:
  ```bash
  kubectl wait --for=condition=ready inferenceservice/iris-model -n kserve-lab --timeout=300s
  ```
  ![is ready](./screenshots/inference-service-ready.png)

**Bước 6: Gửi request suy luận và kiểm tra kết quả**
- Chuẩn bị file dữ liệu đầu vào [`iris-input.json`](./iris-input.json) (bao gồm 2 mẫu hoa Iris):
  ```json
  {
    "instances": [
      [6.8, 2.8, 4.8, 1.4],
      [6.0, 3.4, 4.5, 1.6]
    ]
  }
  ```
- Tiến hành Port-forward cho Service của InferenceService nhằm truy cập từ máy Host:
  ```bash
  kubectl port-forward svc/iris-model-predictor -n kserve-lab 8081:80
  ```
- Thực hiện gửi request suy luận thông qua lệnh curl từ môi trường Terminal mới:
  ```bash
  curl -v http://localhost:8081/v1/models/iris-model:predict -d @input.json -H "Content-Type: application/json"
  ```
- Kết quả thu được từ hệ thống:
  ```json
  {
    "predictions": [1, 1]
  }
  ```
  Kết quả `[1, 1]` thể hiện cả hai mẫu dữ liệu đầu vào đã được phân loại vào loài Iris Versicolor (class 1 trong tập dữ liệu Iris).
  ![curl](./screenshots/inference-result.png)

**Bước 7: Dọn dẹp tài nguyên**
- Tiến hành xóa toàn bộ tài nguyên được tạo ra trong hệ thống sau khi hoàn thành:
  ```bash
  kubectl delete inferenceservice iris-model -n kserve-lab
  kubectl delete job train-iris-model -n kserve-lab
  kubectl delete configmap train-script -n kserve-lab
  kubectl delete pvc model-storage -n kserve-lab
  kubectl delete namespace kserve-lab
  k3d cluster delete kserve-lab
  ```

## 3. Kết quả

## 4. Khó khăn & cách giải quyết

## 5. Reference
- [KServe Documentation](https://kserve.github.io/kserve/latest/)
- [KServe GitHub](https://github.com/kserve/kserve)
- [First InferenceService](https://kserve.github.io/kserve/latest/get_started/first_isvc/)

## 6. Self-check
- [ ] Code chạy được trên máy sạch.
- [ ] README có hướng dẫn run lại.
- [ ] Không hard-code secret.
- [ ] Commit message theo Conventional Commits.
- [ ] Review lại code 1 lượt.
