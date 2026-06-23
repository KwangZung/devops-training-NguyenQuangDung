# Task: CI/CD Basics

- **Intern**: Nguyen Quang Dung
- **Phase / Week / Day**: Phase 1 / Week 2 / Day 6 (W2-D1)
- **Branch**: `phase-1/week-2/day-1-cicd-basics`
- **Submitted at**: `<YYYY-MM-DD HH:MM>`
- **Time spent**: `<số giờ>`

## 1. Mục tiêu
- Hiểu sự khác biệt giữa CI, CD và Continuous Deployment, cũng như các khái niệm quan trọng như DORA metrics.
- Viết được pipeline GitHub Actions/GitLab CI cho ứng dụng `demo-app`.
- Tự động hóa các bước: `lint` -> `test` -> `build & push` image lên GHCR.

## 2. Cách triển khai & Cách chạy
**Cách triển khai (Part B):**
1. Khởi tạo Node.js project (có `package-lock.json`), cấu hình `eslint` và viết 2 test case cơ bản bằng `node:test`.
2. Định nghĩa `Dockerfile` sử dụng multi-stage build với image tĩnh gọn nhẹ (distroless).
3. Tạo file cấu hình tự động hóa `.github/workflows/ci.yml` thiết lập 3 tiến trình (jobs) móc xích với nhau: `lint` -> `test` -> `build-and-push`.
4. Tách mã nguồn thành một Repo riêng biệt và đẩy lên GitHub để luồng CI/CD tự động nhận diện và kích hoạt.

**Cách chạy nội bộ:**
- Tại thư mục chứa dự án:
```bash
npm install
npm run lint
npm test
```
- Trên GitHub: Pipeline sẽ tự động kích hoạt (trigger) khi có thao tác push code hoặc mở Pull Request vào nhánh `main`.

## 3. Kết quả
- Part A - Lý thuyết: [notes.md](./notes.md).
- Link repo có workflow: https://github.com/KwangZung/devops-training-demo-app/tree/main
- Link image trên GHCR: https://github.com/KwangZung/devops-training-demo-app/pkgs/container/demo-app
- Run number: 7
- Hình ảnh minh họa:
  - Pipeline Success: ![Pipeline Success](./screenshots/pipeline-success.png)
  - GHCR Package: ![GHCR Package](./screenshots/ghcr-package.png)

## 4. Khó khăn & cách giải quyết
- **Lỗi từ chối push thư mục Workflow (remote rejected)**: Khi thực hiện lệnh `git push origin main` lần đầu để đẩy mã nguồn và thư mục `.github/workflows/ci.yml` lên GitHub, hệ thống báo lỗi từ chối truy cập vì Personal Access Token lưu trên máy chưa được cấp quyền can thiệp vào file cấu hình pipeline.
  - **Cách giải quyết**: Truy cập vào GitHub Developer Settings, tạo một Personal Access Token mới (classic) và bắt buộc chọn cấp thêm quyền `workflow`. Sau đó, tiến hành cập nhật lại đường dẫn remote tại máy cục bộ bằng lệnh `git remote set-url origin https://<username>:<token_mới>@github.com/...` và thực hiện push code lại thành công.
- **Lỗi thiếu file package-lock.json khi dùng Cache**: Pipeline báo lỗi `Dependencies lock file is not found` ở Job `lint` và `test`. Nguyên nhân do tính năng cache npm của `actions/setup-node` bắt buộc phải có tệp `package-lock.json` để tính toán bộ nhớ đệm, nhưng ban đầu tệp này chưa được đẩy lên.
  - **Cách giải quyết**: Chạy lệnh `npm install` ở trên laptop để hệ thống tự động sinh ra tệp `package-lock.json`, sau đó commit và push tệp này lên repo.
- **Lỗi invalid tag do tên tài khoản chứa chữ in hoa**: Khi chạy Job build Docker Image, hệ thống báo lỗi `repository name must be lowercase`. Nguyên nhân do tên tài khoản GitHub của em (KwangZung) có chứa chữ cái in hoa, trong khi Docker Registry quy định toàn bộ tên kho lưu trữ Image phải viết thường.
  - **Cách giải quyết**: Chèn thêm một bước trung gian vào file `ci.yml` sử dụng lệnh Bash `echo "REPO_OWNER=${OWNER,,}" >> $GITHUB_ENV` để tự động chuyển đổi biến `${{ github.repository_owner }}` thành chữ thường 100% trước khi truyền vào cấu hình gắn thẻ (tags) của Docker.

## 5. Reference
Tài liệu được sử dụng để trả lời các câu hỏi Part A và setup workflow:
- [GitHub Actions — Quickstart](https://docs.github.com/en/actions/quickstart) - Hướng dẫn cơ bản về các khái niệm của GitHub Actions và cách sử dụng runners.
- [GitLab CI — Tutorial](https://docs.gitlab.com/ee/ci/quick_start/) - Tìm hiểu tổng quan về pipeline dưới góc độ của GitLab CI.
- [The Twelve-Factor App](https://12factor.net/) - Nguyên lý 12 yếu tố để xây dựng ứng dụng web SaaS hiện đại.
- [What is CI/CD? (Red Hat)](https://www.redhat.com/en/topics/devops/what-is-ci-cd) - Tài liệu làm rõ khái niệm CI, CD và Continuous Deployment.
- [Are you an Elite DevOps performer? (Google Cloud - DORA)](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance) - Khái niệm về 4 chỉ số DORA trong việc đánh giá hiệu suất đội ngũ phát triển phần mềm.

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
