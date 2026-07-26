# Task Submission Template

## Task: ``

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase  / Week  / `
- **Branch**: `phase-/week-/`
- **Submitted at**: `2026-06-17 23:35` (timezone +07)
- **Time spent**: `5h`

## 1. Mục tiêu

## 2. Cách chạy

**1. Chuẩn bị mã nguồn chứa lỗ hổng (Vulnerable App)**
- Di chuyển vào thư mục Day 3 và khởi tạo dự án:
  ```bash
  cd phase-2/track-mlops-security/week-5/day-3
  mkdir vulnerable_app
  cd vulnerable_app
  ```
- Tạo file quản lý thư viện [`requirements.txt`](./vulnerable_app/requirements.txt) sử dụng các phiên bản cũ đã công bố lỗ hổng:
  ```text
  Django==2.2.0
  urllib3==1.25.10
  ```
- Tạo file mã nguồn [`app.py`](./vulnerable_app/app.py) chứa lỗ hổng SQL Injection và lưu trữ Secret trực tiếp:
  ```python
  import sqlite3

  def get_user_data(user_id):
      query = f"SELECT * FROM users WHERE id = {user_id}"
      conn = sqlite3.connect('example.db')
      cursor = conn.cursor()
      cursor.execute(query)
      return cursor.fetchall()

  # Lỗ hổng Hardcode Secret
  AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
  AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  ```

**2. Thực thi phân tích phần mềm bên thứ ba (SCA) với Grype**
- Tiến hành cài đặt công cụ quét Grype bằng script:
  ```bash
  curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b .
  ```
- Chạy lệnh quét toàn bộ thư mục để dò tìm các CVE từ `requirements.txt`:
  ```bash
  ./grype dir:.
  ```
![grype-results](./screenshots/sca-using-grype.png)

**3. Thực thi phân tích SCA chuyên sâu bằng Snyk và xuất báo cáo HTML (Tùy chọn)**
- Cài đặt Snyk CLI và công cụ xuất HTML thông qua trình quản lý gói npm (yêu cầu đã cài đặt Node.js):
  ```bash
  npm install -g snyk snyk-to-html
  ```
- Thực hiện xác thực tài khoản Snyk (trình duyệt sẽ tự động mở để yêu cầu cấp quyền):
  ```bash
  snyk auth
  ```
- Do thuật toán của Snyk bắt buộc phải phân tích cây phụ thuộc (dependency tree) dựa trên môi trường thực tế, ta cần cài đặt các thư viện này vào máy trước khi quét:
  ```bash
  pip install -r requirements.txt
  ```
- Tiến hành quét lỗ hổng thư viện với tùy chọn `--package-manager=pip` và xuất kết quả ra file HTML:
  ```bash
  snyk test --file=requirements.txt --package-manager=pip --json | snyk-to-html -o snyk_report.html
  ```
- Mở file [`snyk_report.html`](./vulnerable_app/snyk_report.html) vừa tạo bằng bất kỳ trình duyệt web nào để kiểm tra giao diện báo cáo.
![snyk-report](./screenshots/sca-using-snyk.png)

**4. Thực thi phân tích mã nguồn tĩnh (SAST) với Semgrep**
- Cài đặt Semgrep qua pip:
  ```bash
  pip install semgrep
  ```
- *(Lưu ý quan trọng: Ở Bước 3, ta đã cố tình cài đặt bản cũ `urllib3==1.25.10` để phục vụ Snyk. Tuy nhiên, Semgrep lại yêu cầu bản `urllib3` mới hơn. Để tránh lỗi xung đột thư viện "Dependency Hell" làm Semgrep bị sập, ta buộc phải nâng cấp lại thư viện này)*:
  ```bash
  pip install --upgrade urllib3
  ```
- Thực hiện quét mã nguồn bằng bộ luật mặc định (OSS Rules):
  ```bash
  semgrep scan --config auto .
  ```
![semgrep-default-results](./screenshots/sast-using-semgrep-with-default-rule.png)

- Để khắc phục việc Semgrep bản miễn phí cố tình ẩn đi tính năng bắt lỗi Secret, ta tự tạo một file luật tùy chỉnh tên là `rule.yaml` với nội dung sau:
  ```yaml
  rules:
    - id: detect-aws-hardcoded-secret
      languages:
        - python
      message: "[CRITICAL WARNING] Hardcoded AWS Access Key detected! This can lead to cloud system compromise. Never store secrets in source code."
      severity: ERROR
      pattern: |
        AWS_ACCESS_KEY_ID = "..."
  ```
- Chạy lệnh quét lại một lần nữa, kết hợp cả bộ luật mặc định và luật tùy chỉnh:
  ```bash
  semgrep scan --config auto --config rule.yaml .
  ```
![semgrep-custom-rule-results](./screenshots/sast-using-semgrep-with-custom-rule.png)

## 3. Kết quả

## 4. Khó khăn & cách giải quyết

## 5. Reference

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
