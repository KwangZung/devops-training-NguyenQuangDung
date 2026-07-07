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

---

# Báo cáo Lý thuyết Day 2 - Deployment, Service, Ingress

## 1. Deployment: Quản lý vòng đời ứng dụng
Trong thực tế, việc quản lý các Pod độc lập là không hiệu quả vì bản thân Pod không có khả năng self-healing nếu Node chứa nó gặp sự cố. Tài nguyên Deployment ra đời để giải quyết bài toán này.
- **Vai trò**: Deployment là một tài nguyên cấp cao, quản lý trực tiếp các tập hợp bản sao (ReplicaSet). Nó định nghĩa trạng thái mong muốn của ứng dụng (ví dụ: số lượng bản sao, phiên bản Image cần chạy) và đảm bảo trạng thái thực tế trên Cluster luôn khớp với cấu hình đó.
- **Cơ chế cập nhật không gián đoạn (Rolling Update)**: Khi người quản trị thay đổi phiên bản Image, Deployment không tắt toàn bộ hệ thống cũ ngay lập tức. Thay vào đó, nó khởi tạo dần dần các Pod mới và lần lượt loại bỏ các Pod cũ. Nhờ vậy, dịch vụ không bị gián đoạn (zero downtime) trong suốt quá trình nâng cấp.
- **Cơ chế rollback**: Deployment lưu lại lịch sử các lần cập nhật thông qua các cấu hình cũ. Nếu phiên bản mới hoạt động không như mong muốn, người quản trị có thể dễ dàng ra lệnh rollback hệ thống về trạng thái ổn định trước đó với thao tác qua Terminal.

## 2. Service: Kết nối và cân bằng tải nội bộ
Do các Pod mang tính chất tạm thời, địa chỉ mạng của chúng có thể thay đổi bất cứ lúc nào (khi Pod bị chết và được tự động tạo lại). Service cung cấp một điểm truy cập mạng duy nhất, cố định cho một nhóm các Pod đang thực hiện cùng một chức năng.
- **Cơ chế tự động khám phá (Label Selector)**: Service không quản lý trực tiếp danh sách địa chỉ của Pod. Nó sử dụng cơ chế gán nhãn (labels) để tự động phát hiện và liên kết lưu lượng mạng tới tất cả các Pod khớp với điều kiện tìm kiếm. Khi số lượng Pod tăng hoặc giảm, Service tự động cập nhật danh sách đích đến.
- **Phân loại Service cơ bản**:
  - `ClusterIP`: Cấp phát một địa chỉ mạng nội bộ. Dịch vụ chỉ có thể được truy cập từ bên trong Cluster, phù hợp cho kết nối nội bộ giữa ứng dụng và database.
  - `NodePort`: Mở một Port cố định trên tất cả các Node. Việc truy cập vào địa chỉ mạng của bất kỳ Node nào qua Port này đều sẽ được định tuyến thẳng đến Service.
  - `LoadBalancer`: Tích hợp chặt chẽ với các nền tảng điện toán đám mây để tự động cấp phát một bộ cân bằng tải công cộng định tuyến thẳng vào Cluster.

## 3. Ingress: Điều hướng truy cập ngoại mạng
Nếu sử dụng Service loại NodePort hoặc LoadBalancer cho hàng chục ứng dụng, cấu trúc mạng của hệ thống sẽ trở nên phức tạp, rời rạc và rất tốn kém (do phải mua nhiều địa chỉ IP công cộng).
- **Vai trò của Ingress**: Ingress hoạt động ở tầng ứng dụng mạng (tầng 7). Khác với Service thông thường, Ingress đóng vai trò như một bộ định tuyến thông minh duy nhất, tiếp nhận toàn bộ lưu lượng HTTP/HTTPS từ bên ngoài, sau đó điều hướng vào các Service nội bộ tương ứng dựa trên tên miền (Host) hoặc đường dẫn chi tiết (Path).
- **Ingress Controller**: Bản thân tài nguyên Ingress chỉ là một tập hợp các quy tắc định tuyến trên giấy tờ. Để các quy tắc này thực sự có tác dụng, Cluster cần cài đặt một Ingress Controller (ví dụ: ingress-nginx, Traefik). Khi một luật Ingress được khai báo, Ingress Controller sẽ đọc luật đó và tự động tinh chỉnh cấu hình cho bộ định tuyến thực tế (như Nginx).
- **Xử lý bảo mật tập trung (TLS Termination)**: Khi người dùng truy cập web bằng HTTPS, mọi dữ liệu truyền đi đều bị mã hóa. Thay vì bắt từng Pod riêng lẻ phải lưu trữ chứng chỉ và tự giải mã (gây lãng phí tài nguyên và khó quản lý), kỹ thuật TLS Termination giao phó nhiệm vụ này cho Ingress Controller. Ingress Controller sẽ trực tiếp giải mã lưu lượng HTTPS ngay tại cổng vào (kết thúc quá trình mã hóa), sau đó đẩy luồng dữ liệu bản rõ (HTTP thông thường) vào cho các Pod bên trong xử lý một cách nhẹ nhàng.
- **Chứng chỉ tự sinh (Self-signed Certificate)**: Để Ingress Controller có thể mã hóa và giải mã, nó cần một chứng chỉ bảo mật (SSL/TLS Certificate). Trong môi trường thực hành nội bộ (ví dụ: tên miền ảo `app.local`), hệ thống không thể mua chứng chỉ thật từ các tổ chức xác thực. Do đó, kỹ sư thường sử dụng công cụ như `openssl` hoặc `cert-manager` để tự tạo ra một chứng chỉ giả lập (Self-signed) và cấp phát cho Ingress, qua đó mô phỏng hoàn hảo một hệ thống chạy HTTPS an toàn như trong thực tế.