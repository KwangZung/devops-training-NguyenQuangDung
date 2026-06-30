# Part D: Alert
## 1. 3 alert rule bạn sẽ đặt cho web app (latency, error rate, saturation).
Thiết lập 3 alert rules dựa trên 3 chỉ số sau:
- Cảnh báo độ trễ (Latency Alert):
    - Quy tắc: Kích hoạt cảnh báo khi 95% lượng truy cập có thời gian phản hồi vượt quá 2 giây trong suốt 5 phút liên tục.
    - Mục đích: Đảm bảo trải nghiệm người dùng luôn mượt mà. Thời gian phản hồi quá lâu thường là dấu hiệu của việc cơ sở dữ liệu bị nghẽn hoặc thuật toán xử lý đang quá tải.
- Cảnh báo tỷ lệ lỗi (Error Rate Alert):
    - Quy tắc: Kích hoạt cảnh báo khi tỷ lệ các mã lỗi máy chủ (HTTP 5xx) chiếm hơn 1% tổng số lượng truy cập trong vòng 10 phút.
    - Mục đích: Phát hiện ngay lập tức các sự cố nghiêm trọng như sập mạng, lỗi logic mã nguồn hoặc mất kết nối đến cơ sở dữ liệu.
- Cảnh báo mức độ bão hòa (Saturation Alert):
    - Quy tắc: Kích hoạt cảnh báo khi mức sử dụng RAM hoặc dung lượng đĩa cứng của máy chủ vượt quá mức 85% trong khoảng thời gian dài hơn 15 phút.
    - Mục đích: Bắt lỗi trước khi hệ thống cạn kiệt tài nguyên dẫn đến treo toàn bộ hệ thống.

## 2. Cách phân biệt alert "noise" vs alert "actionable".
- Actionable: Cảnh báo thiết thực:
    - Định nghĩa: Là những cảnh báo báo hiệu một vấn đề thực sự đang ảnh hưởng trực tiếp đến người dùng cuối hoặc hệ thống, yêu cầu kỹ sư phải có hành động can thiệp ngay lập tức.
    - Ví dụ: Cảnh báo tỷ lệ lỗi máy chủ tăng vọt lên 5%, hoặc dung lượng ổ đĩa cơ sở dữ liệu chỉ còn 5% là đầy.
    - Đặc điểm: Tần suất xuất hiện thấp, thông điệp rõ ràng, có hướng giải quyết, và mức độ nghiêm trọng cao.
- Noise: Cảnh báo vô ích:
    - Định nghĩa: Là những cảnh báo được gửi ra do hệ thống đạt đến các ngưỡng không quan trọng hoặc hệ thống có khả năng tự khắc phục sau vài giây mà không cần con người can thiệp.
    - Ví dụ: Cảnh báo CPU của máy chủ vọt lên mức 95% chỉ trong vòng 1 phút, do hệ thống đang xử lý một đợt thu thập rác bộ nhớ tự động rồi tự hạ xuống ngay sau đó.
    - Đặc điểm: Tần suất xuất hiện dày đặc, gây nhễu loạn hộp thư, khiến kỹ sư sinh ra tâm lý mệt mỏi và dễ dàng bỏ qua các cảnh báo thiết thực khác.
