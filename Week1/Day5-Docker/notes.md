# Part A — Image internals

### 1. Image gồm những lớp gì? Vì sao layer được cache?

**Image gồm những lớp gì?**
- Một Docker Image không phải là một khối file tĩnh đơn nhất mà được cấu thành từ nhiều lớp chỉ đọc xếp chồng lên nhau, sử dụng công nghệ Union File System.
- Mỗi lớp đại diện cho một thay đổi tương ứng với một lệnh trong `Dockerfile` như `FROM`, `RUN`, `COPY`, `ADD`.
- Lớp dưới cùng thường là hệ điều hành cơ sở như `alpine`, `ubuntu`. Các lớp phía trên chứa cấu hình môi trường, thư viện phụ thuộc, và trên cùng thường là mã nguồn ứng dụng.
- Khi tạo thành container, Docker sẽ thêm một lớp mỏng có thể đọc và ghi lên trên cùng để lưu các thay đổi sinh ra trong lúc container chạy.

**Vì sao layer được cache?**
- Docker thực hiện lưu trữ tạm thời các layer để tăng tốc độ build image ở những lần sau và tiết kiệm băng thông, không gian lưu trữ.
- Khi chạy lệnh `docker build`, Docker sẽ kiểm tra xem cấu trúc lệnh và dữ liệu đầu vào có giống với lần build trước hay không. Nếu giống hệt, nó sẽ dùng lại layer cũ thay vì chạy lại.
- Nếu một layer bị thay đổi, layer đó sẽ phải build lại. Khi layer đó bị build lại, toàn bộ các layer nằm bên trên cũng sẽ bị vô hiệu hóa cache và phải build lại từ đầu. Do đó, người ta thường để các lệnh cài đặt thư viện lên trước lệnh copy source code.

### 2. Sự khác nhau giữa COPY và ADD

- Lệnh `COPY` có chức năng cơ bản là sao chép các file hoặc thư mục từ máy tính của bạn vào bên trong image. Đây là lệnh được khuyến khích sử dụng trong hầu hết các trường hợp do tính rõ ràng và dễ dự đoán của nó.
- Lệnh `ADD` cũng sao chép file từ máy tính vào image nhưng có thêm hai tính năng đặc biệt:
  - Nếu nguồn là một đường dẫn mạng URL thì nó sẽ tự động tải file về và lưu vào image.
  - Nếu nguồn là một file nén chuẩn thì nó sẽ tự động giải nén nội dung file đó vào trong image.
- Do các tính năng ẩn này của `ADD` có thể gây khó hiểu hoặc làm tăng dung lượng image không mong muốn, tài liệu chính thức khuyên nên ưu tiên dùng `COPY` và chỉ dùng `ADD` khi thực sự cần giải nén file tự động.

### 3. CMD vs ENTRYPOINT — khi nào dùng cái nào?

- Lệnh `CMD` định nghĩa tham số hoặc lệnh mặc định sẽ chạy khi container khởi động. Nó có thể dễ dàng bị ghi đè hoàn toàn khi bạn truyền một lệnh khác vào lúc khởi tạo container.
- Lệnh `ENTRYPOINT` định nghĩa một lệnh cố định luôn được thực thi khi container khởi động. Nó không thể bị ghi đè một cách thông thường, mọi tham số truyền thêm từ bên ngoài sẽ được nối vào phía sau lệnh này.
- Khi nào dùng: Dùng `ENTRYPOINT` khi bạn muốn container hoạt động như một công cụ chuyên biệt, luôn phải chạy một phần mềm cốt lõi. Dùng `CMD` để cung cấp các tham số khởi tạo cho `ENTRYPOINT` hoặc khi bạn muốn tạo sự linh hoạt cho phép người dùng chạy một tiến trình khác thay thế.

### 4. Tại sao nên có .dockerignore?

- Giúp giảm dung lượng tổng thể của image bằng cách loại bỏ các file rác, file sinh ra trong lúc code hoặc thư mục môi trường không cần thiết.
- Tăng tốc độ build do hệ thống giảm được khối lượng dữ liệu phải đọc và gửi đi.
- Tránh rò rỉ các thông tin nhạy cảm như mật khẩu, khóa bí mật hoặc file cấu hình cá nhân lên môi trường sản xuất.
- Ngăn chặn việc mất bộ nhớ đệm cache không mong muốn khi một file tạm thời thay đổi.

### 5. EXPOSE thực sự làm gì? Có tự mở port không?

- Lệnh `EXPOSE` hoàn toàn không tự động mở port trên hệ thống mạng của máy chủ thật.
- Chức năng của lệnh này chỉ mang tính chất ghi chú tài liệu, giúp các lập trình viên biết được ứng dụng bên trong container đang lắng nghe ở cổng nào.
- Để thực sự mở port và cho phép truy cập từ bên ngoài, bạn bắt buộc phải sử dụng tham số map port thủ công khi chạy lệnh khởi tạo container.

### 6. Tại sao không nên chạy container as root?

- Giảm thiểu rủi ro bảo mật: Nếu container bị tấn công thông qua một lỗ hổng của ứng dụng, kẻ tấn công sẽ có đặc quyền tối cao bên trong container đó.
- Ngăn chặn leo thang đặc quyền: Một tiến trình chạy quyền cao nhất có khả năng lợi dụng các lỗ hổng của nhân hệ điều hành để thoát ra khỏi sự cách ly của container và chiếm quyền điều khiển máy chủ thực tế.
- Việc sử dụng tài khoản giới hạn quyền hạn giúp thu hẹp phạm vi thiệt hại và đảm bảo ứng dụng chỉ có quyền vừa đủ để hoạt động.
