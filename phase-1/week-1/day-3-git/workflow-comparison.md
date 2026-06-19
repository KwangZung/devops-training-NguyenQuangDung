# Part E — So sánh các mô hình Git Workflow


| Tiêu chí | Trunk-based | GitFlow | GitHub Flow |
|----------|-------------|---------|-------------|
| **Số long-lived branch** | Chỉ có **1** (`main`/`trunk`). Các nhánh phụ (nếu có) thường tồn tại không quá vài ngày. | Có ít nhất **2** (`main` và `develop`). Ngoài ra còn duy trì các nhánh lớn như `release`, `hotfix`. | Chỉ có **1** (`main`). Mọi nhánh tính năng (feature) đều ngắn hạn và merge trực tiếp vào `main`. |
| **Phù hợp scenario nào** | - Đội ngũ dev nhiều senior, kỷ luật cao.<br>- Các dự án Web/SaaS có setup CI/CD tự động xuất sắc.<br>- Cần tốc độ iteration cực nhanh. | - Phần mềm đóng gói truyền thống, app di động có lịch release cứng định kỳ.<br>- Cần maintain nhiều version phần mềm cùng lúc.<br>- Quy trình QA/Testing thủ công. | - Hầu hết các dự án Web app hiện đại.<br>- Dự án Open-source trên GitHub.<br>- Cần sự tinh gọn hơn GitFlow nhưng vẫn an toàn hơn Trunk-based. |
| **Release cadence** | Liên tục deploy. Có thể đẩy lên production nhiều lần mỗi ngày. | Định kỳ theo lịch trình. Phải gom đủ tính năng mới ra mắt. | Thường xuyên. Bất cứ khi nào một Pull Request được review và merge vào `main` là có thể deploy. |
| **Khó khăn khi áp dụng** | - Áp lực cực lớn lên hệ thống test tự động. Code lỗi sẽ làm sập production.<br>- Phải quản lý tốt Feature Flags.<br>- Dev mới khó theo kịp. | - Quy trình cồng kềnh, dễ dẫn đến xung đột.<br>- Flow chậm chạp, không phù hợp với xu hướng Agile hiện đại. | - Thiếu cơ chế kiểm soát nhiều môi trường staging/production phức tạp.<br>- Không phù hợp nếu dự án cần hỗ trợ và vá lỗi cho các phiên bản cũ. |
