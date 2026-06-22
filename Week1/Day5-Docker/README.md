# Task Submission Template

> Mỗi task = 1 thư mục con + 1 PR/MR riêng. Copy template này vào `README.md` của task.

## Task: Day 5: Docker

- **Intern**: Nguyễn Quang Dũng
- **Phase / Week / Day**: Phase 1 / Week 1 / Day 5
- **Branch**: `phase-1/week-1/day-5-docker`
- **Submitted at**: `2026-21-06 21:00`
- **Time spent**: `5h`

## 1. Mục tiêu
- Hiểu và nắm vững các khái niệm Docker cơ bản: Image, Container, Volume, Network.
- Thực hành viết Dockerfile sử dụng Multi-stage build để tối ưu dung lượng Image.
- Dockerize thành công một ứng dụng web (Node.js/Python).
- Push Docker Image lên registry (Docker Hub).

## 2. Cách chạy

## 3. Kết quả

## 4. Khó khăn và cách giải quyết

- **Vấn đề**: Khi sử dụng công cụ `dive` qua Docker container trên WSL để phân tích image, hệ thống báo lỗi `permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock`. Ngoài ra, nếu cài `dive` thông qua Snap thì bị lỗi `cannot find docker client executable` do tính năng cách ly.
- **Nguyên nhân**: Môi trường chạy qua Snap bị giới hạn quyền truy cập không gian thực thi của máy ảo. Đối với việc chạy container `dive`, user mặc định bên trong container không có đủ quyền để truy cập vào socket của Docker (đặc biệt trong trường hợp sử dụng bí danh Podman).
- **Cách giải quyết**:
  - Cấp quyền truy cập đọc và ghi cho docker socket bằng lệnh `sudo chmod 666 /var/run/docker.sock` trước khi thực thi container.
## 5. Tài liệu tham khảo
- [Docker Documentation](https://docs.docker.com/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## 6. Self-check
- [ ] Code chạy được trên máy sạch.
- [ ] README có hướng dẫn chạy lại.
- [ ] Không hard-code secret.
- [ ] Commit message theo Conventional Commits.
- [ ] Đã review lại code một lượt.
