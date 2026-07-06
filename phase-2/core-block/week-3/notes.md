# Báo cáo Lý thuyết Day 1 - k8s architecture, kubectl, install k3d, deploy first pod

## 1. Tổng quan về Kubernetes
Kubernetes (k8s) là một nền tảng điều phối mã nguồn mở được thiết kế để tự động hóa việc triển khai, mở rộng quy mô và vận hành các ứng dụng đóng gói dưới dạng Container.
- **Bối cảnh ra đời**: Khi công nghệ Container (như Docker) trở nên phổ biến để đóng gói và cô lập ứng dụng, một thách thức lớn nảy sinh là làm sao để quản lý, kết nối mạng và duy trì hàng ngàn Container trên nhiều Server vật lý khác nhau. Việc vận hành thủ công là bất khả thi và dễ xảy ra lỗi.
- **Vai trò cốt lõi**: Kubernetes đóng vai trò điều phối toàn bộ các Container này. Hệ thống tự động đảm bảo các Container được chạy trên những Node có đủ tài nguyên, tự động khởi động lại khi ứng dụng bị lỗi (self-healing), cân bằng tải lưu lượng mạng, và cho phép nâng cấp ứng dụng mà không gây gián đoạn dịch vụ. Nhờ đó, việc quản lý hạ tầng lớn trở nên tự động, linh hoạt và minh bạch.

## 2. Kiến trúc Kubernetes (k8s architecture)
Kubernetes được thiết kế theo mô hình phân tán và mở rộng linh hoạt, bao gồm hai nhóm thành phần chính là Control Plane và Worker Node.
- **Control Plane**: Đóng vai trò là bộ não của Cluster. 
  - API Server: Giao diện duy nhất tiếp nhận và xác thực mọi yêu cầu tương tác. Đóng vai trò cầu nối giữa tất cả các thành phần.
  - etcd: Database dạng Key-Value, lưu trữ toàn bộ trạng thái và cấu hình của Cluster với tính nhất quán cực kỳ cao.
  - Scheduler: Lập lịch và quyết định Node phù hợp nhất để triển khai các Pod mới dựa trên yêu cầu tài nguyên và các chính sách ràng buộc.
  - Controller Manager: Vòng lặp điều khiển liên tục theo dõi, so sánh trạng thái thực tế với trạng thái mong đợi và thực hiện các hành động cần thiết để duy trì sự ổn định.
- **Node**: Các Worker Node nơi khối lượng công việc thực sự được xử lý.
  - Kubelet: Tác nhân nền giao tiếp trực tiếp với Control Plane, đảm bảo các Pod được giao đang hoạt động đúng như yêu cầu.
  - Kube-proxy: Thành phần quản lý các quy tắc định tuyến mạng nội bộ để các Pod trên các Node có thể giao tiếp với nhau.
  - Container Runtime: Môi trường chạy nền tảng (như containerd) chịu trách nhiệm tải Image và vận hành thực tế các Container.

## 3. Công cụ quản trị (kubectl)
Đây là công cụ giao tiếp qua Terminal tiêu chuẩn để tương tác với Cluster.
- **Cơ chế hoạt động**: Công cụ này thu thập thông tin về địa chỉ API Server, chứng chỉ bảo mật và bối cảnh sử dụng từ một tệp cấu hình chuyên dụng. Sau đó, nó chuyển đổi các mệnh lệnh của người dùng trên Terminal thành các lời gọi API RESTful tiêu chuẩn để gửi tới API Server.
- **Mô hình tương tác**: Hỗ trợ đồng thời việc ra lệnh trực tiếp (chỉ định thao tác sửa đổi cụ thể trên Terminal) và mô hình khai báo (cung cấp YAML file định nghĩa trạng thái mong muốn để hệ thống tự động thiết lập). Mô hình khai báo là nền tảng cốt lõi cho việc tự động hóa quá trình vận hành hạ tầng.

## 4. Cơ chế cài đặt hệ thống thu gọn (install k3d)
K3d là một công cụ mã nguồn mở được thiết kế để chạy các Cluster K3s bên trong các Container Docker.
- **Đặc điểm kiến trúc**: K3s đã lược bỏ các thành phần nền tảng cũ, đồng thời tối ưu hóa nhân để có thể chạy chỉ bằng một tệp thực thi duy nhất. K3d tận dụng điều kiện này bằng cách gói toàn bộ hệ thống K3s vào trong các Image Docker. Điều này cho phép tạo ra toàn bộ Cluster đa Node dưới dạng nhiều tiến trình riêng biệt trên cùng một Server vật lý.
- **Nguyên lý thiết lập**: việc cài đặt K3d chỉ yêu cầu hệ thống phải có sẵn môi trường Docker. Quá trình khởi tạo Cluster thông qua K3d là quá trình cấu hình mạng nội bộ Docker, định tuyến các Port điều khiển từ môi trường vật lý vào bên trong Cluster ảo, và cuối cùng là tự động sinh ra tệp cấu hình xác thực để công cụ Terminal có thể lập tức tương tác với Cluster ảo đó.

## 5. Quá trình triển khai ứng dụng (deploy first pod)
Pod là đơn vị tính toán nhỏ nhất và cơ bản nhất có thể được quản lý trong hệ thống phân tán này. Quá trình triển khai một Pod không chỉ đơn giản là khởi động một tiến trình, mà là một chuỗi phối hợp chặt chẽ giữa nhiều thành phần:
- **Tiếp nhận yêu cầu**: Khi người dùng phát lệnh triển khai thông qua Terminal, một yêu cầu kèm theo bản phác thảo cấu hình của Pod sẽ được gửi đến API Server. Hệ thống kiểm tra quyền truy cập, xác nhận tính hợp lệ của cấu hình trước khi ghi nhận trạng thái mong muốn mới này vào etcd.
- **Lập lịch phân bổ**: Scheduler liên tục phát hiện các Pod mới đã được lưu lại nhưng chưa được gắn với bất kỳ Node nào. Nó tiến hành phân tích yêu cầu phần cứng của Pod, lọc bỏ các Node không thỏa mãn điều kiện và chấm điểm những ứng viên còn lại. Khi chọn được vị trí tối ưu, Scheduler cập nhật lại thông tin này cho API Server.
- **Thực thi vòng đời**: Tác nhân Kubelet trên Node được chọn phát hiện ra có một nhiệm vụ mới được giao. Nó lập tức thông báo cho Container Runtime tải Image ứng dụng từ Registry, thiết lập các giới hạn tài nguyên và cấu hình CNI. Sau khi Container bắt đầu chạy thành công, Kubelet liên tục theo dõi và phản hồi trạng thái hoạt động trở lại cho API Server để hoàn thiện toàn bộ vòng đời triển khai Pod.