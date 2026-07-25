# Hướng dẫn Triển khai và Báo cáo Thực hành Capstone Project Week 4

## Thông tin nộp bài

- **Intern**: Nguyễn Quang Dũng
- **Phase / Week / Day**: Phase 2 / Week 4 / Capstone
- **Branch**: `phase-2/week-4/capstone`
- **Submitted at**: 2026-07-25
- **Time spent**: 10h

---

## 1. Mục tiêu

- Triển khai toàn bộ ứng dụng VolunteerHub (Frontend React/Vite, Backend Node.js, MongoDB) lên Kubernetes cluster (k3d).
- Quản lý hạ tầng (IaC) bằng Terraform để khởi tạo Namespace và bảo mật Secret cho cơ sở dữ liệu.
- Đóng gói tài nguyên hệ thống bằng Helm Chart.
- Tự động hóa quá trình xây dựng bảo mật (Secure Supply Chain) bằng GitHub Actions (Trivy quét lỗ hổng, Syft xuất SBOM, Cosign ký Image số).
- Triển khai GitOps CD với ArgoCD để đồng bộ tài nguyên tự động.

---

## 2. Kiến trúc và Luồng chạy thực tế

Hệ thống hiện tại được thiết lập để tận dụng tối đa quá trình triển khai CI/CD và định tuyến thông qua Traefik Ingress:
- **Frontend và Backend** giao tiếp thông qua đường dẫn tương đối (`/api`) thay vì hard-code, cho phép Ingress Controller tự động định tuyến.
- **Ingress Controller** sử dụng `traefik` (tích hợp sẵn trong K3d), cấu hình ánh xạ tới cổng `8081` của máy Host. Truy cập ứng dụng không cần cấu hình file `hosts` hay chứng chỉ TLS phức tạp tại môi trường phát triển cục bộ.
- **GitHub Actions (CI)**: Tự động Build ảnh Docker, quét bảo mật và đẩy lên GitHub Container Registry (GHCR).
- **ArgoCD (CD)**: Tự động theo dõi thư mục Helm Chart trên nhánh `main` và đồng bộ xuống k3d cluster.

---

## 3. Cách chạy hệ thống từ đầu

### Bước 1: Tạo Namespace và Secret bằng Terraform
```bash
cd infra/
terraform init
terraform apply --auto-approve
```
*Bước này sẽ tạo Namespace `volunteerhub-prod` và Secret chứa tài khoản truy cập MongoDB nội bộ vào cluster.*

### Bước 2: Thiết lập luồng CI/CD (GitHub Actions)
Sau khi lập trình xong hoặc có bất kỳ thay đổi nào trong thư mục `frontend/` hay `backend/`, chỉ cần thực hiện push code lên GitHub:
```bash
git add .
git commit -m "feat: update code"
git push
```
- Mở tab **Actions** trên GitHub để theo dõi quy trình Build, Scan, Sign, và Push image lên GHCR.

### Bước 3: Đồng bộ trạng thái bằng ArgoCD (GitOps)
- Hệ thống ArgoCD trong K8s được cấu hình để theo dõi thư mục `charts/volunteerhub`.
- Sau khi code trên GitHub được cập nhật, ArgoCD sẽ tự động áp dụng (Sync) Helm Chart xuống K8s.
- *Lưu ý*: Vì K8s sử dụng `imagePullPolicy: Always` cùng với tag `:latest`, nếu cấu trúc Helm không đổi mà chỉ có nội dung Image thay đổi, ta có thể chủ động báo cho K8s kéo Image mới nhất về bằng lệnh:
```bash
kubectl rollout restart deployment volunteerhub-backend -n volunteerhub-prod
kubectl rollout restart deployment volunteerhub-frontend -n volunteerhub-prod
```

### Bước 4: Truy cập Ứng dụng
Mở trình duyệt truy cập vào địa chỉ:
👉 **`http://localhost:8081`**

- Mọi API call từ Frontend sang Backend được tự động định tuyến thông qua Ingress với đường dẫn `/api/...`.
- Đăng nhập bằng Google Auth sẽ tự động gọi vào Backend và chuyển hướng mượt mà không bị lỗi CORS hay sai cổng.

*(Nhớ **Ctrl + F5** hoặc xóa bộ nhớ đệm trình duyệt nếu truy cập lần đầu sau khi cập nhật giao diện).*

---

## 4. Kết quả
- Hệ thống có khả năng tự động hóa 100% quá trình cập nhật mã nguồn lên môi trường K8s nội bộ.
- Loại bỏ hoàn toàn lỗi hardcode `localhost:5000`, tăng tính bảo mật và khả năng mở rộng.

## 5. Khó khăn & cách giải quyết
- **Lỗi Frontend hard-code URL tuyệt đối**: Chức năng Google Auth và các trang gọi API liên tục báo lỗi do trình duyệt cố gọi tới `localhost:5000`. Cố gắng tiêm biến môi trường `.env` qua K8s không thành công vì GitHub Actions build code mà không có `.env` (file này nằm trong `.gitignore`).
- **Cách giải quyết**: Refactor toàn bộ code Frontend sang dùng đường dẫn tương đối (`/api/auth/google`, `axios.get("/api/...")`). Nginx và Ingress Traefik sẽ đảm nhiệm phần còn lại, tự động chuyển tiếp các request có `/api` vào đúng Backend Pod.

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
