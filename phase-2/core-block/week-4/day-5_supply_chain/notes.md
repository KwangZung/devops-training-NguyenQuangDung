# Ghi chú lý thuyết Day 5: Supply Chain Security

## 1. Trivy - Image Scanning
Trivy là một công cụ quét lỗ hổng bảo mật toàn diện cho các container image, file system và Git repository.
- **Tính năng chính**:
  - Quét OS packages (Alpine, RHEL, CentOS, Ubuntu, Debian).
  - Quét language-specific packages (npm, yarn, pip, composer).
  - Quét cấu hình IaC (Terraform, Dockerfile, Kubernetes).
- **Vai trò quan trọng**: Giúp phát hiện sớm các lỗ hổng (CVEs) trong các thư viện và base image. Từ đó ngăn chặn việc đưa các image có rủi ro cao lên môi trường production.
- **Cách hoạt động**: Sử dụng cơ sở dữ liệu lỗ hổng được cập nhật liên tục để đối chiếu với các package có trong image.

## 2. SBOM (Software Bill of Materials) - Sinh bằng Syft
- **Khái niệm SBOM**: Là "bảng thành phần" của phần mềm, chứa thông tin chi tiết về mọi thành phần, thư viện mã nguồn mở và dependency được sử dụng để build phần mềm đó.
- **Tầm quan trọng**:
  - Tăng tính minh bạch cho toàn bộ chuỗi cung ứng.
  - Hỗ trợ việc theo dõi và khoanh vùng các lỗ hổng nhanh chóng (ví dụ Log4Shell) mà không cần phân tích lại toàn bộ source code.
- **Syft**: Là một CLI tool giúp tạo SBOM từ container image hoặc folder. Hỗ trợ định dạng xuất chuẩn như SPDX, CycloneDX.

## 3. Cosign - Image Signing & Verification
- **Khái niệm Cosign**: Là công cụ thuộc dự án Sigstore, dùng để ký (sign), xác thực (verify) container image và lưu trữ chữ ký trên OCI registry.
- **Cơ chế Keyless Signing**: Hỗ trợ ký xác thực qua OIDC (OpenID Connect), giúp loại bỏ rủi ro lộ hoặc mất private key. Việc ký dựa trên định danh của hệ thống CI/CD (như GitHub Actions).
- **Quy trình áp dụng**:
  1. Build image thành công.
  2. Dùng lệnh cosign ký lên image (tạo signature).
  3. Đẩy image và signature lên registry.
  4. Tại workflow CD hoặc qua Admission Controller, tiến hành xác thực chữ ký (verify). Nếu image không có signature hợp lệ sẽ bị từ chối (reject).
