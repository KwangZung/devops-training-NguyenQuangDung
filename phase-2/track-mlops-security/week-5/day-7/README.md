# Task Submission Template

## Task: `Week 5 - Day 7 (Mini Lab: Tích hợp DevSecOps Pipeline)`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 5 / 7`
- **Branch**: `phase-2/week-5`
- **Submitted at**: `2026-07-27 10:59` (timezone +07)
- **Time spent**: `6h`

## 1. Mục tiêu

## 2. Cách chạy
**Bước 1: Khởi tạo luồng GitHub Actions (CI/CD Pipeline)**
- Mục tiêu của bài Lab tổng hợp này là xâu chuỗi tất cả các công cụ bảo mật rời rạc (Semgrep, Grype, TruffleHog, Trivy, ZAP) vào chung một quy trình tự động hóa duy nhất.
- Tại thư mục gốc của dự án, tiến hành tạo thư mục chứa cấu hình Workflow của GitHub Actions (nếu chưa có):
  ```bash
  mkdir -p .github/workflows
  ```
- Tạo file `.github/workflows/devsecops-pipeline.yml` và cấu hình luồng chạy như sau:
  ```yaml
  name: Complete DevSecOps Pipeline

  on:
    push:
      branches: [ "phase-2/week-5" ]

  jobs:
    # Trạm 1: Quét mã nguồn và rò rỉ Secret
    sast-and-secret:
      runs-on: ubuntu-latest
      steps:
        - name: Checkout code
          uses: actions/checkout@v3
          with:
            fetch-depth: 0 # Bắt buộc để TruffleHog quét lịch sử
        
        - name: Secret Scanning (TruffleHog)
          uses: trufflesecurity/trufflehog@main
          with:
            path: ./
            base: ""
            head: ${{ github.ref_name }}
            
        - name: SAST Scanning (Semgrep)
          run: |
            python -m pip install semgrep
            semgrep scan --config auto .

    # Trạm 2: Quét lỗ hổng thư viện (Chỉ chạy nếu Trạm 1 qua cửa)
    sca-scanning:
      needs: sast-and-secret
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Run Grype vulnerability scanner
          uses: anchore/scan-action@v3
          with:
            path: "."
            fail-build: true

    # Trạm 3: Quét Container Image
    container-security:
      needs: sca-scanning
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Build Docker Image
          run: docker build -t my-app:latest phase-2/track-mlops-security/week-5/day-5/trivy_lab/
        - name: Run Trivy vulnerability scanner
          uses: aquasecurity/trivy-action@master
          with:
            image-ref: 'my-app:latest'
            format: 'table'
            exit-code: '1' # Kích hoạt Gate Fail
            ignore-unfixed: true
            vuln-type: 'os,library'
            severity: 'CRITICAL,HIGH'

    # Trạm 4: Kiểm thử Động (DAST)
    dast-testing:
      needs: container-security
      runs-on: ubuntu-latest
      steps:
        - name: Checkout code
          uses: actions/checkout@v3
        - name: Deploy temporary test container (Juice Shop for demo)
          run: docker run -d -p 3000:3000 bkimminich/juice-shop
        - name: OWASP ZAP Baseline Scan
          uses: zaproxy/action-baseline@v0.10.0
          with:
            target: 'http://localhost:3000'
            fail_action: true # Gate Fail
  ```

**Bước 2: Phân tích cơ chế Gate Fail toàn tập**
- Trong đoạn cấu hình YAML trên, ta đã thiết lập một rào chắn 4 lớp cực kỳ nghiêm ngặt:
  - **Sast-and-secret:** Nếu có mã độc hoặc lộ Key -> Vỡ trận.
  - **Sca-scanning:** Nếu thư viện dính CVE -> Vỡ trận.
  - **Container-security:** Nếu hệ điều hành của Docker dính CVE mức độ HIGH/CRITICAL -> Vỡ trận.
  - **Dast-testing:** Nếu bị tấn công thành công qua cổng Web HTTP -> Vỡ trận.
- Chỉ khi ứng dụng hoàn toàn trong sạch, vượt qua cả 4 ải kiểm duyệt (Exit Code 0), Pipeline mới cho phép đi đến bước Deploy cuối cùng (không có trong lab này). Bất cứ lỗi nào (Exit Code 1) cũng sẽ làm Pipeline đỏ chót.

**Bước 3: Kích hoạt Pipeline**
- Thực hiện Commit và Push toàn bộ bài thực hành (bao gồm cả thư mục `.github`) lên nhánh `phase-2/week-5` để đánh thức GitHub Actions:
  ```bash
  git add .
  git commit -m "feat: integrate full devsecops pipeline"
  git push origin phase-2/week-5
  ```
- Mở trình duyệt, truy cập vào giao diện GitHub của Repo dự án, chuyển sang tab **Actions** để tận mắt theo dõi tiến trình Pipeline đang vượt rào qua từng trạm kiểm soát (Jobs).
- *(Chèn ảnh chụp màn hình giao diện GitHub Actions hiển thị luồng Pipeline hoàn chỉnh tại đây)*.

## 3. Kết quả

## 4. Khó khăn & cách giải quyết

## 5. Reference

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
