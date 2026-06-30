# Part A: Notes
## 1. Phân biệt log vs metric vs trace (ví dụ cụ thể).
- Metric (Chỉ số đo lường): Là các chỉ số số học theo thời gian (ví dụ: CPU 50%, RAM 80%, số requests/giây, tỉ lệ thanh toán lỗi trong vòng 10 phút vừa qua, ...).
- Log (Nhật ký): Là các dòng văn bản ghi lại chi tiết một sự kiện cụ thể (ví dụ: "User login successfully", "Payment failed").
- Trace (Truy vết): Là chuỗi các hành động chi tiết của một yêu cầu khi đi qua nhiều service. (ví dụ: Khi một giao dịch bị lỗi, trace ghi lại hành trình: Người dùng bấm thanh toán -> Dịch vụ Giỏ hàng (xử lý mất 10 mili giây) -> Dịch vụ Kho bãi (xử lý mất 20 mili giây) -> Dịch vụ Cổng thanh toán (mất tới 5000 mili giây và trả về lỗi).)

## 2. Pull-based (Prometheus) vs Push-based (StatsD, OpenTelemetry collector) — ưu nhược.
- Mô hình thu thập dữ liệu pull-based: Trong mô hình này, máy chủ giám sát trung tâm như Prometheus đóng vai trò chủ động. Theo một chu kỳ nhất định (ví dụ cứ mỗi 15 giây), nó sẽ đi đến gõ cửa từng máy chủ con để yêu cầu lấy dữ liệu về.
    - Ưu điểm: 
        - Quản lý tải trọng tốt: Vì máy chủ trung tâm tự quyết định lúc nào đi lấy dữ liệu và lấy với tốc độ bao nhiêu, nó sẽ không bao giờ bị quá tải do nhận được quá nhiều dữ liệu cùng lúc.
        - Tự động phát hiện lỗi cực kỳ nhanh nhạy: Đây là ưu điểm lớn nhất. Nếu máy chủ trung tâm gõ cửa mà không thấy máy con phản hồi, nó ngay lập tức biết rằng máy con đó đã sập và có thể phát ngay cảnh báo.
        - Cấu hình tập trung: Bạn chỉ cần khai báo danh sách các máy con tại một nơi duy nhất là máy chủ trung tâm.
    - Nhược điểm:
        - Bất cập với mạng bảo mật khắt khe: bắt buộc phải port trên từng máy con để máy chủ trung tâm có thể đi vào được, điều này đôi khi bị giới hạn bởi các chính sách tường lửa.
        - Điểm yếu với các tác vụ vòng đời ngắn: Nếu có một tác vụ tính toán chỉ chạy trong 5 giây rồi tắt, nhưng chu kỳ kéo của Prometheus là 15 giây, thì dữ liệu của tác vụ đó sẽ biến mất trước khi Prometheus kịp tới lấy.
- Mô hình thu thập dữ liệu push-based: ở mô hình này máy chủ giám sát (như StatsD) đóng vai trò thụ động. Nó chỉ việc ngồi một chỗ, và các máy chủ con sẽ chủ động đóng gói dữ liệu rồi gửi thẳng về trung tâm.
    - Ưu điểm:
        - Bắt được các tác vụ ngắn hạn: Các tiến trình chạy rất ngắn (như hàm điện toán không máy chủ) chỉ cần xử lý xong công việc, đẩy thẳng kết quả về trung tâm rồi tắt ngang mà không sợ bị sót dữ liệu.
        - Thân thiện với mạng khép kín: Máy con có thể nằm sâu trong mạng nội bộ, chỉ cần được phép gọi đường truyền ra bên ngoài là có thể đẩy dữ liệu đi, không cần phải mở cổng mạng để cho phép kết nối ngược từ ngoài vào.
    - Nhược điểm:
        - Rủi ro sập hệ thống trung tâm cao: Nếu hàng chục ngàn máy con đồng loạt gặp lỗi và cùng xả dữ liệu báo cáo về trung tâm một lúc, hệ thống giám sát có thể bị nghẽn mạng hoặc sập hoàn toàn vì không đỡ kịp tải.
        - Khó phân biệt trạng thái chết hay đang rảnh rỗi: Nếu máy chủ trung tâm không nhận được dữ liệu từ một máy con trong một thời gian dài, nó không thể biết chắc chắn là máy con đó đã sập, hay chỉ đơn giản là máy con đó đang rảnh rỗi nên không có dữ liệu gì để gửi về.

## 3. SLI / SLO / SLA khác nhau thế nào? Cho 1 ví dụ.
- SLI (Service Level Indicator): Một thước đo định lượng được xác định cẩn thận về một khía cạnh cụ thể của mức độ dịch vụ đang được cung cấp.
    - Ví dụ: Tỷ lệ phần trăm các giao dịch thanh toán thành công trên tổng số giao dịch đo được trong hệ thống hiện tại là 99,5%.
- SLO (Service Level Objective): Một giá trị mục tiêu hoặc một phạm vi giá trị cụ thể được đặt ra cho một mức độ dịch vụ, được đo lường thông qua chỉ báo tương ứng.
    - Ví dụ: Tỷ lệ phần trăm các giao dịch thanh toán thành công phải đạt mức lớn hơn hoặc bằng 99,0% trong chu kỳ 30 ngày liên tục.
- SLA (Service Level Agreement): Một bản hợp đồng hoặc thỏa thuận với người dùng, trong đó quy định rõ các hậu quả nếu hệ thống không đạt được các mục tiêu đã cam kết.
    - Ví dụ: Nếu tỷ lệ giao dịch thanh toán thành công trong tháng rớt xuống dưới 98,0%, công ty sẽ hoàn lại 10% phí dịch vụ cho khách hàng.

## 4. Cardinality nổ là gì, hậu quả?
- Định nghĩa: Là hiện tượng mà hệ thống giám sát phải ghi chép lại các chỉ số theo những tiêu chí phân loại có vô số giá trị khác nhau, dẫn đến tiêu tốn tài nguyên hệ thống
- Ví dụ: Khi ta theo dõi chỉ số _tổng số lượng truy cập_, ta gắn thêm 2 nhãn phân loại là _phương thức giao tiếp_ (chỉ có 4 giá trị cơ bản: GET, POST, PUT, DELETE) và _mã trạng thái trả về_ (chỉ có 5 giá trị cơ bản: 200, 201, 400, 404, 500). Khi này hệ thống chỉ phải tạo tối đa 20 chuỗi thời gian. Nhưng nếu gắn thêm 1 nhãn phân loại _user_id_ chỉ id của người truy cập nữa, hệ thống sẽ phải tạo 1 chuỗi thời gian mới tương ứng với mỗi người dùng truy cập. Điều này rất dễ dẫn đến cạn kiệt tài nguyên của hệ thống.
- Hậu quả: 
    - Tốn nhiều dung lượng lưu trữ.
    - Làm hệ thống xử lý chậm, thậm chí có nguy cơ  treo hệ thống.