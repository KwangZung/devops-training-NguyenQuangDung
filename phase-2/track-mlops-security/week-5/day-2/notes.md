# Lý thuyết Week 5 - DevSecOps & MLOps

## Day 2: MLOps - Data Versioning với DVC (Data Version Control)

### Tổng quan về DVC
Trong quá trình phát triển mô hình Machine Learning, việc quản lý phiên bản mã nguồn bằng hệ thống Git là chưa đủ. Dữ liệu (Dataset) và các file có kích thước lớn (Model artifacts) thường xuyên biến đổi theo thời gian nhưng không thể lưu trữ trực tiếp trên Git do giới hạn nghiêm ngặt về dung lượng cũng như hiệu năng.

DVC (Data Version Control) là một công cụ mã nguồn mở ra đời nhằm giải quyết vấn đề này. DVC hoạt động song song và tích hợp chặt chẽ với Git, mang lại những tính năng quan trọng sau:
- **Quản lý phiên bản dữ liệu**: Lưu trữ và truy xuất các mốc lịch sử của tập dữ liệu huấn luyện tương tự như cách Git quản lý mã nguồn.
- **Tối ưu hóa lưu trữ**: DVC sử dụng cơ chế con trỏ (pointer) dưới dạng các file văn bản nhỏ (file `.dvc`) để theo dõi các file dữ liệu lớn. Các file `.dvc` này sẽ được đẩy lên Git, trong khi dữ liệu thực tế được đồng bộ tới các kho lưu trữ từ xa (Remote Storage) như Amazon S3, Azure Blob Storage hoặc MinIO.
- **Tái tạo kết quả (Reproducibility)**: Ràng buộc chặt chẽ dữ liệu, mã nguồn và mô hình tại cùng một thời điểm commit, giúp khôi phục lại chính xác trạng thái của bất kỳ thực nghiệm nào trong quá khứ.

### Nguyên lý hoạt động của DVC

Khi một file dữ liệu lớn được đưa vào hệ thống thông qua lệnh `dvc add`, DVC sẽ âm thầm thực hiện các bước xử lý sau:
1. Tính toán giá trị mã băm (Hash) dựa trên nội dung của file dữ liệu hiện tại.
2. Di chuyển file dữ liệu thực tế vào thư mục bộ đệm nội bộ (DVC Cache).
3. Tạo ra một file theo dõi `.dvc` (ví dụ: `dataset.csv.dvc`) chứa thông tin siêu dữ liệu (metadata) bao gồm mã Hash, kích thước và đường dẫn tương đối của file gốc.
4. Tự động thêm đường dẫn file dữ liệu gốc vào danh sách `.gitignore` để ngăn hệ thống Git theo dõi nhầm các file có dung lượng lớn.

Từ thời điểm này, ta chỉ cần sử dụng lệnh `git add` và `git commit` đối với file `.dvc` thay vì file dữ liệu gốc. Khi chuyển đổi qua lại giữa các branch hoặc quay về các mốc thời gian cũ bằng lệnh `git checkout`, ta chỉ cần chạy thêm lệnh `dvc checkout`. DVC sẽ tự động đối chiếu thông tin trong file `.dvc` hiện hành và khôi phục file dữ liệu thực tế tương ứng từ thư mục Cache (hoặc tải về từ Remote Storage) đưa trở lại không gian làm việc.

### Quản lý Remote Storage

DVC cung cấp tính năng đồng bộ hóa dữ liệu từ Cache nội bộ lên các kho lưu trữ dùng chung thông qua khái niệm Remote. Tính năng này cho phép các kỹ sư chia sẻ bộ dữ liệu và mô hình lớn cho toàn bộ nhóm làm việc mà không cần đính kèm vào kho lưu trữ mã nguồn.

Ví dụ về việc cấu hình lưu trữ bằng Amazon S3:
```bash
dvc remote add -d myremote s3://my-bucket/dvcstore
```
Câu lệnh trên thiết lập một Remote lưu trữ mặc định (cờ `-d`) trỏ đến một Bucket cụ thể trên S3. Sau đó, quá trình đẩy dữ liệu lên (Push) hoặc kéo dữ liệu về (Pull) có thể được thực hiện hoàn toàn tự động thông qua các lệnh `dvc push` và `dvc pull`.
