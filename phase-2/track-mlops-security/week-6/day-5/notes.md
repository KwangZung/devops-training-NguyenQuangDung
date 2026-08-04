# Lý thuyết Week 6 - Day 5: Image Scanning & CI/CD Integration (Cosign)

## 1. Mảnh ghép còn thiếu của Supply Chain Security
Trong các bài thực hành trước, Trivy đã được sử dụng để quét Vulnerabilities trong Image. Nếu Image đạt chuẩn an toàn, nó sẽ được đẩy lên Docker Registry để Kubernetes (như k3d) tiến hành kéo về và chạy.

Tuy nhiên, mô hình này vẫn tồn tại rủi ro trong Supply Chain:
- Kẻ tấn công có thể xâm nhập vào Docker Registry, thay thế Image an toàn bằng một Image chứa mã độc nhưng vẫn giữ nguyên tên và tag.
- Kubernetes sẽ kéo Image độc hại đó về và thực thi trên môi trường Production mà không có cơ chế xác minh nguồn gốc.

Để giải quyết vấn đề này, kiến trúc Zero-Trust áp dụng khái niệm Image Signing.

## 2. Cosign & Dự án Sigstore
Cosign, một công cụ thuộc dự án Sigstore của Linux Foundation, là tiêu chuẩn hiện nay để thực hiện quá trình sign và verify Container Image. 

Cosign hoạt động dựa trên cơ chế Asymmetric Cryptography:
1. **Khởi tạo khóa**: Cosign sinh ra một cặp khóa gồm Private Key (sử dụng nội bộ) và Public Key (công khai).
2. **Quy trình Sign**: Sau khi build và quét Trivy hoàn tất, Private Key được dùng để ký lên Image. Cosign tính toán Digest của Image, mã hóa bằng Private Key và đẩy chữ ký này lên Registry, đặt song song với Image gốc.
3. **Quy trình Verify**: Thông qua Public Key, hệ thống có thể kiểm tra nguồn gốc của Image. Bất kỳ sự thay đổi nào đối với nội dung Image sẽ dẫn đến sự sai lệch mã Hash, khiến chữ ký trở nên không hợp lệ.

## 3. Vai trò của Admission Controller (Kyverno)
Chữ ký số cần được kiểm tra tự động trước khi Image được cấp phép chạy trên cluster. Do đó, một Admission Controller đóng vai trò thiết yếu để từ chối các Image không xác định hoặc có chữ ký không hợp lệ.

- **Kyverno**: Là một Policy Engine thiết kế chuyên biệt cho Kubernetes, sử dụng file cấu hình YAML thay vì ngôn ngữ Rego phức tạp.
- **Tích hợp Cosign**: Kyverno cung cấp khả năng giao tiếp trực tiếp với cơ chế xác minh của Cosign. Khi nhận được yêu cầu triển khai Pod từ API Server, Kyverno đối chiếu thông tin Image với Public Key đã cấu hình. Quá trình triển khai chỉ tiếp tục nếu chữ ký được xác thực thành công.
