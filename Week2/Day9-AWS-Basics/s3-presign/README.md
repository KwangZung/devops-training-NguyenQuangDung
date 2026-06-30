# Part D: S3 Presigned URL

Script Python sử dụng thư viện `boto3` để sinh ra một Presigned URL cho phép đọc/tải file `private.pdf` từ bucket private. Đường dẫn sinh ra chỉ có hiệu lực trong vòng 5 phút (300 giây) bảo đảm tính an toàn bảo mật.

## Yêu cầu môi trường
- Python 3.x
- `boto3` library

## Hướng dẫn sử dụng
1. Cài đặt thư viện AWS SDK cho Python:
```bash
pip install boto3
```

3. Chạy script để lấy link:
```bash
python presign.py
```
