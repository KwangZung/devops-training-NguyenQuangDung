# Day 6 - CI/CD Basics: Part A - Lý thuyết

## 1. CI / CD / Continuous Deployment khác nhau thế nào?
- **CI (Continuous Integration)**: Tích hợp mã nguồn liên tục. Mỗi khi có code mới đẩy lên repo, hệ thống tự động tiến hành build và chạy tests để phát hiện sớm các lỗi tích hợp.
- **Continuous Delivery (Giao hàng liên tục)**: Đảm bảo code luôn ở trạng thái sẵn sàng để có thể deploy lên môi trường production bất kỳ lúc nào. Tuy nhiên, việc thực sự deploy lên production vẫn cần có sự phê duyệt thủ công.
- **Continuous Deployment (Triển khai liên tục)**: Tự động hóa hoàn toàn quy trình phát hành. Mọi thay đổi vượt qua các bước kiểm tra tự động sẽ được đẩy thẳng lên môi trường production mà không cần sự can thiệp của con người.

## 2. DORA 4 key metrics là gì? Ý nghĩa từng metric.
DORA (DevOps Research and Assessment) đưa ra 4 chỉ số cốt lõi để đo lường hiệu suất phát triển phần mềm:
1. **Deployment Frequency (Tần suất triển khai)**: Đo lường mức độ thường xuyên mà mã nguồn mới được triển khai thành công lên môi trường production. Phản ánh tốc độ cung cấp giá trị.
2. **Lead Time for Changes (Thời gian triển khai thay đổi)**: Khoảng thời gian từ lúc một commit được thực hiện đến khi nó chạy trên môi trường production. Đo lường tốc độ của quy trình phát hành.
3. **Change Failure Rate (Tỷ lệ triển khai lỗi)**: Tỷ lệ phần trăm số lần triển khai lên production dẫn đến suy thoái dịch vụ và cần có biện pháp khắc phục (ví dụ: rollback, hotfix). Phản ánh chất lượng của các thay đổi.
4. **Time to Restore Service / Mean Time to Recovery (Thời gian phục hồi dịch vụ)**: Thời gian trung bình để khôi phục hệ thống từ lúc xảy ra sự cố trên production. Phản ánh khả năng ứng phó sự cố và phục hồi của hệ thống.

## 3. Pipeline as Code có ưu điểm gì so với cấu hình UI?
- **Quản lý phiên bản (Version Control)**: Do là code, nó có thể được lưu trữ cùng mã nguồn, có commit history, giúp dễ dàng theo dõi và rollback khi cần.
- **Code Review**: Mọi sự thay đổi về quy trình CI/CD đều có thể được rà soát thông qua cơ chế Pull Request/Merge Request.
- **Tính nhất quán và tái sử dụng**: Có thể dùng như một template, dễ dàng copy/paste, tái sử dụng (reusable workflows) trên nhiều dự án khác nhau.
- **Giảm sai sót con người**: Loại bỏ rủi ro do nhấp sai cấu hình trên giao diện UI, việc cấu hình luôn minh bạch và nhất quán.

## 4. Khi nào dùng `runs-on: self-hosted` vs `ubuntu-latest`?
- **Dùng `ubuntu-latest` (chạy trên máy ảo của Github)**: 
  - Phù hợp cho đa số các dự án cơ bản không có nhu cầu đặc biệt về phần cứng hay mạng lưới.
  - Mang tính tiện dụng cao: không cần thiết lập, không cần quản lý, được tự động cập nhật, môi trường cách ly sẵn sàng sử dụng ngay.
- **Dùng `self-hosted` (chạy trên máy do mình tự cài đặt)**:
  - Khi quy trình CI/CD đòi hỏi cấu hình phần cứng đặc biệt mạnh hoặc hệ điều hành đặc thù.
  - Khi cần bảo mật mạng nội bộ (truy cập vào các tài nguyên nội bộ sau tường lửa, database tại cơ sở, v.v.).
  - Khi số phút chạy CI của dự án quá lớn, có thể tiết kiệm chi phí mua GitHub Actions bằng cách dùng hạ tầng tự có.
