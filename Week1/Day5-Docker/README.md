# Task Submission Template

> Mỗi task = 1 thư mục con + 1 PR/MR riêng. Copy template này vào `README.md` của task.

## Task: Day 5: Docker

- **Intern**: Nguyễn Quang Dũng
- **Phase / Week / Day**: Phase 1 / Week 1 / Day 5
- **Branch**: `phase-1/week-1/day-5-docker`
- **Submitted at**: `2026-23-06 10:00`
- **Time spent**: `7h`

## 1. Mục tiêu
- Hiểu và nắm vững các khái niệm Docker cơ bản: Image, Container, Volume, Network.
- Thực hành viết Dockerfile sử dụng Multi-stage build để tối ưu dung lượng Image.
- Dockerize thành công một ứng dụng web (Node.js/Python).
- Push Docker Image lên registry (Docker Hub).

## 2. Cách chạy

### Part B — Dockerize 1 web app

**Bước 1: Build Docker Image**
Chạy lệnh sau tại thư mục chứa Dockerfile:
```bash
docker build -t demo-app:1.0.0 .
```

**Bước 2: Khởi chạy container**
```bash
docker run --rm -p 3000:3000 -e NAME=phase1 demo-app:1.0.0
```

**Bước 3: Kiểm tra dung lượng image**
```bash
docker image ls demo-app
```

**Bước 4: Security Scan bằng Trivy**
*(Lưu ý: Nếu dùng Podman, cần bật dịch vụ API trước để Trivy giao tiếp trực tiếp thay vì phải xuất image ra file `.tar`)*
```bash
# Bật socket giao tiếp cho Podman (chạy ngầm)
podman system service -t 0 &

# Quét trực tiếp và xuất báo cáo định dạng Markdown qua template
trivy image --format template --template "@markdown.tpl" -o security-report.md demo-app:1.0.0
```

### Part D — Push image

**Bước 1: Đăng nhập vào Docker Hub**
```bash
docker login
```

**Bước 2: Đổi tên image theo tên đăng nhập Docker Hub**
```bash
docker tag demo-app:1.0.0 kazu912/demo-app:1.0.0
```

**Bước 3: Đẩy image lên repo trực tuyến**
```bash
docker push kazu912/demo-app:1.0.0
```

**Bước 4: Xóa image trên máy và thử pull từ Docker Hub**
```bash
# Xóa image local để chắc chắn Docker sẽ phải tải từ trên mạng về
docker rmi kazu912/demo-app:1.0.0
docker run --rm -p 3000:3000 -e NAME=phase1 kazu912/demo-app:1.0.0
```

### Part E — Bonus

**So sánh dung lượng các loại Base Image**
Để thấy sự khác biệt, ta sẽ build ứng dụng `demo-app` với 4 base image khác nhau.


1. Sửa thành: FROM node:20 AS runtime
```bash
docker build -t demo-app:node20 .
```

2. Sửa thành: FROM node:20-slim AS runtime
```bash
docker build -t demo-app:slim .
```

3. Bản alpine đã build ở Part B
```bash
docker tag demo-app:1.0.0 demo-app:alpine
```

4. Bản Distroless

File Dockerfile:

```dockerfile
# Stage 1: Builder
FROM node:20 AS builder
WORKDIR /app
COPY app/server.js ./app/server.js

# Stage 2: Runtime với Distroless
FROM gcr.io/distroless/nodejs20-debian11 AS runtime
LABEL org.opencontainers.image.title="Day 5 Demo App" \
      org.opencontainers.image.description="A simple Node.js web app for Docker practice" \
      org.opencontainers.image.version="1.0.0"

WORKDIR /app
COPY --from=builder /app/app/server.js ./app/server.js

USER nonroot
EXPOSE 3000

CMD ["app/server.js"]
```

Sau khi lưu dockerfile, chạy lệnh build:
```bash
docker build -t demo-app:distroless .
```

5. Kiểm tra dung lượng để thấy sự khác biệt của ứng dụng khi dùng các base khác nhau:
```bash
docker image ls | grep demo-app
```
![Kết quả so sánh dung lượng](./screenshots/part-e-size-comparison.png)

## 3. Kết quả

### Part B — Dockerize 1 web app

**1. Kết quả lệnh build thành công**
![Kết quả build image](./screenshots/part-b-build.png)

**2. Kết quả khởi chạy container và curl**
![Kết quả run và curl](./screenshots/part-b-run-curl.png)

**3. Kết quả kiểm tra dung lượng image**
![Kết quả image size](./screenshots/part-b-image-size.png)

**4. Báo cáo Security Scan**
Kết quả quét dưới định dạng Markdown được đính kèm trong file: [security-report.md](./security-report.md)

### Part D — Push image

**1. Kết quả lệnh Push, lệnh run sau khi xóa để kiểm tra pull**
![Kết quả push image](./screenshots/part-d-push.png)

**2. Link Image trên Docker Hub**: https://hub.docker.com/r/kazu912/demo-app

### Part E — Bonus

**1. Báo cáo Security Scan**
Đã thực hiện bằng công cụ Trivy và ghi nhận kết quả tại file `security-report.md` (Chi tiết chạy lệnh xem ở Part B).

**2. So sánh dung lượng Base Image**
![Kết quả so sánh dung lượng](./screenshots/part-e-size-comparison.png)

## 4. Khó khăn và cách giải quyết

- **Vấn đề với lệnh dive**: Khi sử dụng công cụ `dive` qua Docker container trên WSL để phân tích image, hệ thống báo lỗi `permission denied while trying to connect to the Docker daemon socket`.
  - **Nguyên nhân**: User mặc định bên trong container không có đủ quyền để truy cập vào socket của Docker, đặc biệt khi hệ thống đang sử dụng Podman thay vì Docker thuần.
  - **Cách giải quyết**: Cấp quyền truy cập đọc và ghi cho docker socket bằng lệnh `sudo chmod 666 /var/run/docker.sock` trước khi thực thi container.

- **Vấn đề với công cụ quét bảo mật Trivy trên Podman**: Khi cài Trivy qua Snap và quét trực tiếp, báo lỗi không tìm thấy image hoặc socket.
  - **Nguyên nhân**:
    1. Trivy bản Snap bị giới hạn bởi sandbox khắt khe, không được phép chui vào kho image rootless của Podman.
    2. Podman theo cơ chế không chạy nền (daemonless), nên mặc định không mở cổng API socket, khiến ngay cả Trivy native cũng báo lỗi `no podman socket found`.
  - **Cách giải quyết triệt để**:
    1. Gỡ bản Snap (`sudo snap remove trivy`), xóa bộ nhớ đệm lệnh (`hash -r`) và cài đặt bản native từ script chính thức của Aqua Security.
    2. Chủ động bật dịch vụ API của Podman chạy ngầm bằng lệnh: `podman system service -t 0 &`.
    3. Tạo file `markdown.tpl` và yêu cầu Trivy quét thẳng image, in ra report dạng markdown theo template: `trivy image --format template --template "@markdown.tpl" -o security-report.md demo-app:1.0.0`.

- **Vấn đề khi build image với Distroless**: Khi đổi base image sang `gcr.io/distroless/nodejs20-debian11`, tiến trình build báo lỗi `stat /bin/sh: no such file or directory` ở dòng `RUN chown`.
  - **Nguyên nhân**: Đặc trưng của Distroless là bị lược bỏ sạch sẽ mọi thành phần hệ điều hành cơ bản (không có shell `/bin/sh`, không có các lệnh core OS như `chown`, `mkdir`, `wget`...). Do đó, các chỉ thị trong Dockerfile gọi lệnh OS (như `RUN`) sẽ thất bại ngay lập tức.
  - **Cách giải quyết**: Phải thiết kế lại cấu trúc Dockerfile ở stage runtime riêng cho Distroless: xóa bỏ lệnh `RUN chown`, xóa bỏ `HEALTHCHECK` (vì không có `wget`), dùng user `nonroot` có sẵn của Distroless, và chỉnh lại `CMD` gọi thẳng file js.

## 5. Tài liệu tham khảo
- [Docker Documentation](https://docs.docker.com/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn chạy lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code một lượt.
