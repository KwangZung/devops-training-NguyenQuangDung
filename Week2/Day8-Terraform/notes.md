# Day-8 Terraform
## Part A: Lý thuyết

**1. State file là gì? Vì sao không được commit lên Git?**
State file là nơi Terraform lưu trữ trạng thái hiện tại của hệ thống cơ sở hạ tầng. Terraform dùng nó để đối chiếu giữa mã nguồn và thực tế nhằm xác định những thay đổi cần thực hiện.
Tuyệt đối không đẩy tệp này lên hệ thống quản lý mã nguồn vì nó lưu trữ mọi thông tin dưới dạng văn bản không mã hóa, bao gồm cả các mật khẩu hoặc khóa bí mật. Hơn nữa, khi nhiều người cùng làm việc và đẩy tệp này lên, nguy cơ xảy ra xung đột dữ liệu trạng thái là rất cao, dẫn đến hỏng cấu hình hạ tầng.

**2. So sánh `terraform plan` vs `terraform apply` vs `terraform refresh`**
- terraform plan: Đọc mã nguồn và so sánh với tệp state hiện tại để lên kế hoạch thi công. Lệnh này chỉ hiển thị những thay đổi dự kiến mà không tác động thực sự đến hạ tầng.
- terraform apply: Bắt đầu thực thi các thay đổi dựa trên kế hoạch đã lập. Lúc này hạ tầng thực tế mới chính thức được tạo mới, cập nhật hoặc xóa bỏ.
- terraform refresh: Chủ động truy vấn trạng thái thực tế từ hệ thống đám mây để cập nhật lại tệp state ở máy trạm, đảm bảo tệp state đồng bộ với tình trạng thực tế của hạ tầng.

**3. Tại sao nên dùng remote backend (S3 + DynamoDB lock)?**
Khi làm việc nhóm, việc lưu trữ tệp state tập trung qua remote backend giúp mọi người luôn truy cập vào cùng một phiên bản trạng thái mới nhất.
Bộ lưu trữ S3 cung cấp nơi lưu trữ tệp tin an toàn và có tính sẵn sàng cao.
Cơ sở dữ liệu DynamoDB cung cấp cơ chế khóa trạng thái. Khi một người đang chạy lệnh thay đổi hạ tầng, hệ thống sẽ khóa tệp state lại, ngăn chặn người khác vô tình chạy lệnh đồng thời gây ra xung đột hoặc lỗi nghiêm trọng.

**4. So sánh module local vs registry**
- Module local: Là các đoạn mã cấu hình được định nghĩa cục bộ trong cùng một dự án. Ưu điểm là dễ dàng chỉnh sửa và kiểm thử ngay lập tức, phù hợp cho các cấu hình mang tính chất đặc thù của dự án.
- Module registry: Là các đoạn mã cấu hình được đóng gói và chia sẻ trên thư viện lưu trữ trung tâm. Ưu điểm là tính tái sử dụng cao, đã được cộng đồng kiểm chứng, giúp tiết kiệm thời gian triển khai các kiến trúc tiêu chuẩn.

**5. `count` vs `for_each` — khi nào dùng cái nào?**
- count: Sử dụng khi cần tạo nhiều tài nguyên có cấu hình giống hệt nhau, trong đó thứ tự của tài nguyên không quan trọng. Hạn chế của nó là khi thêm hoặc xóa một phần tử ở giữa danh sách, toàn bộ các phần tử phía sau sẽ bị ảnh hưởng, khiến Terraform có thể xóa và tạo lại nhầm tài nguyên.
- for_each: Sử dụng khi cần tạo nhiều tài nguyên nhưng mỗi tài nguyên có các thuộc tính cấu hình riêng biệt dựa trên một bảng dữ liệu. Nó gán định danh cố định cho từng tài nguyên, giúp việc thêm bớt phần tử ở giữa danh sách diễn ra an toàn mà không ảnh hưởng đến các tài nguyên khác.

**6. `Drift` là gì, cách phát hiện & xử lý?**
Drift là sự khác biệt giữa cấu hình được định nghĩa trong mã nguồn và tình trạng thực tế của hệ thống. Điều này thường xảy ra khi có người thực hiện thay đổi hạ tầng bằng tay thông qua giao diện điều khiển thay vì dùng lệnh Terraform.
- Cách phát hiện: Chạy lệnh terraform plan, hệ thống sẽ báo cáo những khác biệt chưa được ghi nhận.
- Cách xử lý: Chạy lệnh terraform apply để buộc hạ tầng thực tế quay trở về đúng với cấu hình trong mã, hoặc cập nhật mã nguồn để khớp với tình trạng hiện tại của hạ tầng thực tế.
