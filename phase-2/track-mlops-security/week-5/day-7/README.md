# Task Submission Template

## Task: `Week 5 - Day 7 (Mini Lab: Tích hợp DevSecOps Pipeline)`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 5 / 7`
- **Branch**: `phase-2/week-5`
- **Submitted at**: `2026-07-27 10:59` (timezone +07)
- **Time spent**: `6h`

## 1. Mục tiêu

## 2. Cách chạy
**Bước 1: Chuẩn bị mã nguồn Machine Learning**
- Tạo thư mục chứa mã nguồn bài Lab:
  ```bash
  mkdir -p phase-2/track-mlops-security/week-5/day-7/ml-lab
  ```
- Tạo file [`phase-2/track-mlops-security/week-5/day-7/ml-lab/train.py`](./ml-lab/train.py) (Mô phỏng huấn luyện mô hình, ghi log vào MLflow, cố tình chứa mật khẩu AWS và hàm nguy hiểm `eval()`):
  ```python
  import mlflow
  import os

  # Lỗi bảo mật 1: Rò rỉ Secret Key của AWS S3 (nơi DVC lưu trữ dữ liệu)
  AWS_SECRET_KEY = "AKIAIOSFODNN7EXAMPLE" 
  
  # Lỗi bảo mật 2: Sử dụng hàm nguy hiểm eval()
  user_input = "print('MLOps Training Started')"
  eval(user_input)

  with mlflow.start_run():
      mlflow.log_param("epochs", 50)
      mlflow.log_metric("accuracy", 0.95)
      print("Model trained and logged to MLflow successfully!")
  ```
- Tạo file [`phase-2/track-mlops-security/week-5/day-7/ml-lab/requirements.txt`](./ml-lab/requirement.txt) (Dùng thư viện cũ để Grype bắt lỗi):
  ```text
  mlflow==2.1.0
  scikit-learn==1.2.0
  requests==2.19.0
  Flask==0.12.2
  ```
- Tạo file [`phase-2/track-mlops-security/week-5/day-7/ml-lab/Dockerfile`](./ml-lab/Dockerfile)(Đóng gói API, dùng base image cũ để Trivy bắt lỗi):
  ```dockerfile
  FROM python:3.9-buster
  WORKDIR /app
  COPY requirements.txt .
  RUN pip install -r requirements.txt
  COPY train.py .
  CMD ["python", "train.py"]
  ```

**Bước 2: Cấu hình MLOps Security Pipeline giới hạn phạm vi quét**
- Để tránh các công cụ đi quét linh tinh vào các bài tập cũ, ta sẽ thiết lập tham số `path` ép chúng chỉ quét đúng thư mục `ml-lab`.
- Tạo thư mục Workflow ở gốc dự án (nếu chưa có):
  ```bash
  mkdir -p .github/workflows
  ```
- Tạo file [`.github/workflows/mlops-pipeline.yaml`](../../../../.github/workflows/mlops-pipeline.yaml) và dán cấu hình sau:
  ```yaml
  name: MLOps Security Pipeline

  on:
    push:
      branches: [ "phase-2/week-5" ]
      # Chỉ kích hoạt Pipeline nếu có thay đổi trong thư mục day-7
      paths:
        - 'phase-2/track-mlops-security/week-5/day-7/**'

  jobs:
    sast-and-secret:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
          with:
            fetch-depth: 0 
        - name: Secret Scanning (TruffleHog)
          uses: trufflesecurity/trufflehog@main
          with:
            path: ./ 
            base: ""
            head: ${{ github.ref_name }}
        - name: SAST Scanning (Semgrep)
          if: always() # Bắt buộc chạy dù TruffleHog phía trước có Gate Fail (Exit 183)
          run: |
            python -m pip install semgrep
            semgrep scan --config auto phase-2/track-mlops-security/week-5/day-7/ml-lab/

    sca-scanning:
      # Chạy song song độc lập, không dùng 'needs' để tránh bị block
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Run Grype vulnerability scanner
          uses: anchore/scan-action@v3
          env:
            GRYPE_DB_MAX_ALLOWED_BUILT_AGE: "87600h" # Bỏ qua lỗi DB quá hạn (Mặc định Grype báo lỗi nếu DB cũ hơn 5 ngày)
          with:
            path: "phase-2/track-mlops-security/week-5/day-7/ml-lab/"
            fail-build: true

    mlops-training:
      # Chạy song song độc lập
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Set up Python
          uses: actions/setup-python@v4
          with:
            python-version: '3.9'
        - name: Install dependencies
          run: pip install -r phase-2/track-mlops-security/week-5/day-7/ml-lab/requirements.txt
        - name: Pull Data (DVC) and Train Model (MLflow)
          run: |
            echo "Simulating DVC pull from remote storage..."
            cd phase-2/track-mlops-security/week-5/day-7/ml-lab
            python train.py

    container-security:
      # Chạy song song độc lập
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Build Docker Image
          run: docker build -t ml-api:latest phase-2/track-mlops-security/week-5/day-7/ml-lab/
        - name: Run Trivy vulnerability scanner
          uses: aquasecurity/trivy-action@master
          with:
            image-ref: 'ml-api:latest'
            format: 'table'
            exit-code: '1' 
            ignore-unfixed: true
            vuln-type: 'os,library'
            severity: 'CRITICAL,HIGH'

    # Trạm cuối: Triển khai Model
    deploy-model:
      # Job này chỉ được chạy khi CẢ 4 JOB TRÊN đều Pass (Exit Code 0)
      needs: [sast-and-secret, sca-scanning, mlops-training, container-security]
      runs-on: ubuntu-latest
      steps:
        - name: Deploy to Production
          run: echo "All security checks passed, deploying model to production..."
  ```

**Bước 3: Kích hoạt Pipeline trên GitHub**
- Khi push toàn bộ thay đổi này lên nhánh `phase-2/week-5` là Pipeline sẽ tự động được kích hoạt:
- Kết quả: ngoại trừ job `mlops-training`, cả 3 job còn lại đều fail, nên model sẽ không được deploy
![sast secret](./screenshots/sast-and-secret-result.png)
![sca](./screenshots/sca-scanning-failed.png)
![train](./screenshots/mlops-training-succeed.png)
![container security](./screenshots/container-security-failed.png)

## 3. Kết quả

## 4. Khó khăn & cách giải quyết

## 5. Reference

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
