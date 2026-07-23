# Tổng quan lý thuyết Prometheus, Grafana, Loki và kube-prometheus-stack

Tài liệu này tổng hợp chi tiết lý thuyết về các công cụ giám sát, thu thập log và cảnh báo trong Kubernetes Cluster thuộc nội dung Day 4 của chương trình đào tạo DevSecOps.

---

## 1. Prometheus

Prometheus là một hệ thống giám sát và cảnh báo mã nguồn mở, hoạt động theo mô hình Time Series Database (TSDB). Prometheus được thiết kế tối ưu cho các môi trường cloud-native và container hóa như Kubernetes.

### Kiến trúc và các thành phần chính

Hệ thống Prometheus bao gồm nhiều thành phần phối hợp hoạt động:

- **Prometheus Server**: Thành phần chính của hệ thống, đảm nhận ba nhiệm vụ chính:
  - **Retrieval**: Thu thập metric từ các target được cấu hình.
  - **TSDB**: Lưu trữ dữ liệu metric dưới dạng chuỗi thời gian một cách hiệu quả.
  - **HTTP Server**: Cung cấp API và giao diện web để thực thi các câu truy vấn PromQL.
- **Service Discovery**: Cơ chế tự động phát hiện target cần giám sát trong hệ thống động như Kubernetes, AWS, Consul... giúp tự động hóa cấu hình mà không cần cập nhật thủ công.
- **Exporters**: Các tiến trình trung gian chuyển đổi metric từ các hệ thống không hỗ trợ Prometheus gốc sang định dạng Prometheus. Ví dụ: Node Exporter thu thập metric của hệ điều hành, Blackbox Exporter kiểm tra tính khả dụng của endpoint qua HTTP/TCP.
- **Pushgateway**: Thành phần trung gian nhận metric từ các short-lived jobs. Do các job này kết thúc nhanh chóng trước khi Prometheus kịp kéo dữ liệu, chúng sẽ gửi metric lên Pushgateway để Prometheus kéo về sau.
- **Alertmanager**: Thành phần xử lý cảnh báo được gửi từ Prometheus Server, thực hiện phân phối và định tuyến thông báo đến các kênh như Slack, Email, Webhook.

### Cơ chế hoạt động: Pull model so với Push model

Prometheus hoạt động chính theo mô hình Pull model:

- **Mô hình Pull**: Prometheus Server chủ động gửi yêu cầu HTTP GET tới các target (được expose qua endpoint `/metrics`) theo chu kỳ cấu hình (scrape interval) để lấy dữ liệu.
  - **Ưu điểm**:
    - Giảm tải cho các target vì không cần quản lý logic gửi dữ liệu hay xử lý hàng đợi kết nối.
    - Dễ dàng phát hiện target bị lỗi (nếu không kéo được dữ liệu, Prometheus sẽ báo trạng thái DOWN ngay lập tức).
    - Dễ dàng kiểm tra thủ công bằng cách truy cập trực tiếp vào endpoint `/metrics` của target từ trình duyệt hoặc lệnh curl.
    - Tránh tình trạng quá tải cho server giám sát, vì server tự quyết định tần suất và thời điểm kéo dữ liệu.
- **Mô hình Push**: Các target chủ động gửi dữ liệu lên server giám sát.
  - **Ưu điểm**: Thích hợp cho các short-lived jobs hoặc hệ thống nằm sau NAT/Firewall mà server không thể truy cập trực tiếp.
  - **Nhược điểm**: Khó kiểm soát tải trên server giám sát nếu số lượng target gửi dữ liệu tăng đột biến; khó phát hiện target bị sập nếu target đó không gửi dữ liệu.

### Định dạng dữ liệu và các kiểu Metric

Mỗi chuỗi thời gian trong Prometheus được định nghĩa bởi tên metric cùng một tập hợp các nhãn dưới dạng key-value:

`metric_name{label_key1="label_value1", label_key2="label_value2"} value`

Prometheus cung cấp bốn kiểu metric chính:

- **Counter**: Một chỉ số tích lũy chỉ tăng dần theo thời gian hoặc reset về 0 khi tiến trình khởi động lại. Counter thường dùng để đếm tổng số lượng yêu cầu, số lỗi phát sinh hoặc số tác vụ hoàn thành.
- **Gauge**: Một chỉ số đại diện cho một giá trị đo lường đơn lẻ có thể tăng hoặc giảm một cách tùy ý. Gauge thường dùng để giám sát dung lượng bộ nhớ sử dụng, số lượng Pod đang chạy hoặc nhiệt độ hệ thống.
- **Histogram**: Đo lường tần suất xuất hiện của các giá trị (như thời gian phản hồi hoặc kích thước yêu cầu) và phân bổ chúng vào các khoảng giá trị được cấu hình trước. Histogram cung cấp ba thông tin:
  - Tổng số lượng quan sát (hệ số `_count`).
  - Tổng giá trị của tất cả quan sát (hệ số `_sum`).
  - Số lượng quan sát nằm trong mỗi bucket (hệ số `_bucket{le="<upper_bound>"}`).
- **Summary**: Tương tự như Histogram, dùng để đo lường thời gian phản hồi hoặc kích thước yêu cầu, nhưng Summary tính toán các phân vị trực tiếp trên client trước khi gửi về Prometheus Server. Summary cung cấp tổng số lượng quan sát, tổng giá trị và các phân vị cụ thể (ví dụ: `quantile="0.95"`).

#### So sánh Histogram và Summary

- **Histogram**: Tính toán phân vị trên server sử dụng hàm `histogram_quantile()`. Histogram có thể gộp dữ liệu từ nhiều target khác nhau để tính phân vị chung, tuy nhiên cần cấu hình trước các bucket hợp lý để tránh sai số.
- **Summary**: Tính toán phân vị trên client. Summary cho kết quả phân vị chính xác hơn mà không cần cấu hình bucket trước, nhưng không thể gộp dữ liệu từ nhiều target với nhau và tiêu tốn tài nguyên tính toán của target client.

### Ngôn ngữ truy vấn PromQL

PromQL (Prometheus Query Language) là ngôn ngữ truy vấn chức năng được thiết kế riêng để xử lý dữ liệu chuỗi thời gian của Prometheus.

- **Instant Vector**: Tập hợp các chuỗi thời gian chứa một điểm dữ liệu duy nhất cho mỗi chuỗi tại thời điểm hiện tại. Ví dụ: `http_requests_total`.
- **Range Vector**: Tập hợp các chuỗi thời gian chứa một loạt các điểm dữ liệu trong một khoảng thời gian xác định. Ví dụ: `http_requests_total[5m]` lấy dữ liệu trong 5 phút gần nhất.
- **Một số toán tử và hàm phổ biến**:
  - `rate(http_requests_total[5m])`: Tính tốc độ tăng trung bình mỗi giây của counter trong khoảng thời gian 5 phút. Hàm này chỉ sử dụng trên Range Vector và trả về Instant Vector.
  - `irate(http_requests_total[5m])`: Tính tốc độ tăng tức thời dựa trên hai điểm dữ liệu gần nhất trong khoảng thời gian 5 phút, thích hợp cho các đồ thị có độ biến động nhanh.
  - `sum(rate(http_requests_total[5m])) by (status)`: Gộp tổng tốc độ yêu cầu theo mã trạng thái HTTP.
  - `increase(http_requests_total[1h])`: Tính toán mức tăng thực tế của counter trong vòng 1 giờ qua.

---

## 2. Alertmanager

Alertmanager đảm nhận vai trò quản lý, xử lý và gửi thông báo cảnh báo sau khi nhận được thông tin từ Prometheus Server.

### Quy trình xử lý cảnh báo (Alerting Pipeline)

1. **Định nghĩa luật cảnh báo (Alerting Rules)**: Được cấu hình trên Prometheus Server dưới dạng file YAML. Nếu biểu thức PromQL thỏa mãn điều kiện trong khoảng thời gian `for`, alert sẽ chuyển sang trạng thái firing.
2. **Gửi cảnh báo**: Prometheus Server gửi các cảnh báo đang firing sang Alertmanager qua giao thức HTTP POST theo chu kỳ.
3. **Xử lý tại Alertmanager**: Alertmanager thực hiện các bước lọc nhiễu, gom nhóm, tắt tạm thời và định tuyến trước khi gửi tới receiver cuối cùng.

### Các tính năng chính của Alertmanager

- **Deduplication**: Khi triển khai nhiều Prometheus Server chạy song song để đảm bảo tính sẵn sàng cao, cả hai server sẽ gửi cùng một cảnh báo đến Alertmanager. Alertmanager sẽ tự động nhận diện và gộp chúng lại để tránh gửi trùng lặp thông báo tới người dùng.
- **Grouping**: Gộp các cảnh báo có tính chất tương tự nhau thành một thông báo duy nhất nhằm tránh tình trạng ngập lụt cảnh báo khi xảy ra sự cố diện rộng. Ví dụ, nếu cả Cluster bị mất kết nối mạng và hàng trăm Pod đồng loạt báo lỗi, Alertmanager sẽ gộp tất cả các lỗi Pod đó vào một thông báo theo nhãn của Cluster hoặc Namespace.
- **Inhibition**: Cơ chế tắt các cảnh báo cấp thấp nếu một cảnh báo gốc có mức độ nghiêm trọng cao hơn đang diễn ra. Ví dụ, nếu cảnh báo toàn bộ Node bị sập đang hoạt động, Alertmanager sẽ tự động tắt các cảnh báo phụ như Pod trên Node đó bị dừng hoạt động hoặc Service trên Node đó không phản hồi.
- **Silencing**: Cho phép người vận hành tắt thông báo của một số cảnh báo cụ thể trong một khoảng thời gian xác định (ví dụ: trong quá trình bảo trì định kỳ hệ thống). Cấu hình silencing dựa trên việc so khớp các nhãn.
- **Routing**: Định tuyến cảnh báo dựa trên cấu hình cây định tuyến trong file cấu hình. Cảnh báo sẽ được chuyển tiếp tới các receiver khác nhau (như Slack, Email, PagerDuty, Webhook) tùy thuộc vào các nhãn nhắm mục tiêu (như `severity="critical"` gửi tới PagerDuty, `severity="warning"` gửi tới Slack).

---

## 3. Grafana

Grafana là công cụ trực quan hóa dữ liệu và phân tích chỉ số mã nguồn mở phổ biến nhất hiện nay, cho phép xây dựng các Dashboard động và tùy biến cao từ nhiều nguồn dữ liệu khác nhau.

### Tính năng chính trong giám sát hệ thống

- **Kết nối đa nguồn dữ liệu**: Hỗ trợ tích hợp nhiều nguồn dữ liệu cùng lúc như Prometheus (metrics), Loki (logs), Tempo (traces), Elasticsearch, PostgreSQL... trong cùng một giao diện.
- **Dashboard và Panel**: Dashboard được cấu tạo từ nhiều Panel. Mỗi Panel đại diện cho một biểu đồ trực quan (như Time Series, Stat, Gauge, Table, Bar Chart). Ta có thể viết các câu truy vấn PromQL trực tiếp trong Panel để lấy dữ liệu vẽ đồ thị.
- **Variables**: Cho phép tạo ra các bộ lọc động ở phía trên Dashboard (như chọn Namespace, Node, Pod cụ thể). Khi thay đổi giá trị biến, các câu truy vấn trong các Panel sẽ tự động cập nhật theo giá trị được chọn.
- **Grafana Alerting**: Hệ thống cảnh báo tích hợp của Grafana, cho phép định nghĩa các điều kiện cảnh báo trực tiếp trên các Panel trực quan hóa và gửi thông báo qua nhiều kênh tương tự Alertmanager.

---

## 4. Grafana Loki

Grafana Loki là một hệ thống thu thập và quản lý log tập trung được thiết kế với triết lý tối giản, hiệu quả và tiết kiệm chi phí, lấy cảm hứng từ Prometheus.

### Triết lý thiết kế và Sự khác biệt so với Elasticsearch

Điểm khác biệt quan trọng nhất giữa Grafana Loki và các hệ thống log truyền thống như Elasticsearch hay Splunk nằm ở cách lập chỉ mục:

- **Elasticsearch**: Lập chỉ mục toàn bộ nội dung của log. Điều này giúp tìm kiếm văn bản cực kỳ nhanh chóng nhưng tiêu tốn rất nhiều dung lượng lưu trữ và tài nguyên CPU, RAM để duy trì index khổng lồ.
- **Grafana Loki**: Chỉ lập chỉ mục các nhãn metadata đi kèm với log stream (tương tự như nhãn của metric trong Prometheus). Nội dung log thực tế không được lập chỉ mục mà được nén lại thành các chunks và lưu trữ trực tiếp trên các dịch vụ Object Storage giá rẻ.
  - **Lợi ích**:
    - Dung lượng index cực kỳ nhỏ, có thể lưu trữ trực tiếp trên RAM hoặc ổ cứng dung lượng thấp.
    - Tiết kiệm chi phí lưu trữ log lên tới nhiều lần so với Elasticsearch.
    - Tốc độ ghi log rất cao do không phải tốn thời gian phân tích từ vựng và xây dựng index chi tiết cho từng dòng log.
  - **Đánh đổi**: Truy vấn tìm kiếm các chuỗi văn bản cụ thể trong nội dung log sẽ chậm hơn Elasticsearch ở quy mô lớn, vì Loki phải quét qua các chunks dữ liệu thô. Tuy nhiên, hiệu năng này được bù đắp bằng cơ chế phân chia truy vấn song song thông qua thành phần Querier.

### Kiến trúc các thành phần của Loki

Loki có thể chạy ở chế độ Single Binary hoặc Microservices với các thành phần chính sau:

- **Distributor**: Cổng tiếp nhận log đầu vào từ các log collector agent. Distributor kiểm tra tính hợp lệ của log, phân chia log thành các stream dựa trên nhãn và phân phối tới các Ingester phù hợp.
- **Ingester**: Nhận dữ liệu log từ Distributor, gom các dòng log lại thành các chunks trong bộ nhớ, thực hiện nén dữ liệu và ghi các chunks này xuống Object Storage định kỳ. Ingester cũng lưu trữ tạm thời các log mới nhất trong bộ nhớ RAM để phục vụ các truy vấn tức thời.
- **Querier**: Tiếp nhận yêu cầu truy vấn từ người dùng (qua Grafana hoặc API). Querier sẽ tìm kiếm các chunks liên quan dựa trên index nhãn, sau đó tải các chunks này từ Storage hoặc lấy trực tiếp từ Ingester (đối với log chưa được ghi xuống disk) để lọc nội dung theo yêu cầu và trả về kết quả.
- **Log Collector**:
  - **Promtail**: Agent thu thập log truyền thống của Loki. Nó chạy dưới dạng DaemonSet trên từng Node trong Kubernetes, phát hiện log file từ các container, gắn các nhãn metadata cần thiết (như namespace, pod_name, container_name) và gửi tới Loki.
  - **Lưu ý**: Promtail đã dừng hỗ trợ và khuyến nghị chuyển đổi sang Grafana Alloy để thực hiện thu thập metric, log và trace đồng nhất.

### Ngôn ngữ truy vấn LogQL

LogQL là ngôn ngữ truy vấn của Loki, có cú pháp tương tự PromQL. Một truy vấn LogQL gồm hai phần chính: Log Stream Selector và Filter Expression.

- **Log Stream Selector**: Lọc các luồng log dựa trên nhãn. Ví dụ: `{app="nginx", env="prod"}`.
- **Filter Expression**: Bộ lọc văn bản để tìm kiếm nội dung log cụ thể.
  - `{app="nginx"} |= "error"`: Lấy các dòng log của ứng dụng nginx có chứa chuỗi "error".
  - `{app="nginx"} != "info"`: Lấy các dòng log không chứa chuỗi "info".
- **Metric Queries**: Chuyển đổi dữ liệu log thành metric chuỗi thời gian để tính toán và vẽ đồ thị.
  - `sum(rate({app="nginx"}[5m]))`: Tính tổng tốc độ dòng log của ứng dụng nginx trong 5 phút qua.
  - `count_over_time({app="nginx"} |= "error" [10m])`: Đếm số lượng dòng log chứa từ "error" của ứng dụng nginx trong vòng 10 phút qua.

---

## 5. kube-prometheus-stack và Prometheus Operator

Để triển khai và quản lý toàn bộ hệ thống giám sát trên Kubernetes một cách dễ dàng và đồng nhất, cộng đồng DevOps sử dụng Helm Chart `kube-prometheus-stack` kết hợp với Prometheus Operator.

### Giới thiệu kube-prometheus-stack

`kube-prometheus-stack` là một Helm Chart tổng hợp, giúp cài đặt và cấu hình tự động một hệ thống giám sát toàn diện trong Kubernetes Cluster. Các thành phần được cài đặt sẵn bao gồm:

- **Prometheus Operator**: Quản lý vòng đời của Prometheus và Alertmanager.
- **Prometheus**: Instance thu thập và lưu trữ metric.
- **Alertmanager**: Quản lý và định tuyến cảnh báo.
- **Grafana**: Tích hợp sẵn giao diện trực quan hóa và các dashboard hệ thống mặc định.
- **Node Exporter**: Thu thập metric phần cứng và hệ điều hành của các Node trong Cluster.
- **Kube-State-Metrics**: Lắng nghe Kubernetes API và tạo ra các metric về trạng thái của các đối tượng Kubernetes (như số lượng replica mong muốn của Deployment, trạng thái sẵn sàng của Pod, tài nguyên request/limit của Container).

### Khái niệm và vai trò của Prometheus Operator

Prometheus Operator áp dụng mô hình Operator Pattern trong Kubernetes nhằm tự động hóa các tác vụ quản trị hệ thống giám sát. Thay vì phải cấu hình thủ công file `prometheus.yml` và khởi động lại Prometheus mỗi khi có thay đổi target, Prometheus Operator sử dụng các Custom Resource Definitions (CRDs) để định nghĩa cấu hình giám sát một cách khai báo.

Operator liên tục giám sát Kubernetes API để phát hiện các tài nguyên CRD này và tự động dịch chúng thành file cấu hình chuẩn của Prometheus/Alertmanager, sau đó reload cấu hình một cách an toàn mà không làm gián đoạn hệ thống.

### Các Custom Resource Definitions (CRDs) quan trọng

- **`Prometheus`**: Định nghĩa một Deployment hoặc StatefulSet chạy Prometheus Server trong Cluster. Tài nguyên này cho phép cấu hình số lượng replica, dung lượng lưu trữ, thời gian lưu trữ metric (retention), cũng như định nghĩa các bộ lọc nhãn (ServiceMonitorSelector, PodMonitorSelector) để quyết định Prometheus sẽ nhận cấu hình scrape từ những tài nguyên nào.
- **`Alertmanager`**: Định nghĩa một Deployment hoặc StatefulSet chạy Alertmanager trong Cluster, quản lý cấu hình cluster Alertmanager và số lượng bản sao.
- **`ServiceMonitor`**: Định nghĩa cách giám sát một nhóm các Kubernetes Services. Đây là CRD quan trọng nhất giúp thực hiện GitOps cho monitoring. Ta chỉ cần định nghĩa nhãn của Service cần giám sát (ví dụ: selector match nhãn `app: backend`), ServiceMonitor sẽ tự động tìm kiếm các Endpoint của Service đó và cấu hình Prometheus scrape metrics từ chúng.
- **`PodMonitor`**: Tương tự như ServiceMonitor nhưng nhắm mục tiêu trực tiếp tới các Pod mà không cần thông qua Service của Kubernetes.
- **`PrometheusRule`**: Định nghĩa các luật cảnh báo (Alerting Rules) và luật ghi nhận (Recording Rules) bằng cú pháp YAML của Kubernetes. Prometheus Operator sẽ tự động phát hiện tài nguyên PrometheusRule và nạp các luật này vào Prometheus Server.
