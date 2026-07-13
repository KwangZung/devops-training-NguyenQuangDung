# Lý thuyết Day 1 & Day 2: Terraform

## Day 1: Terraform Module & Remote Backend

### 1. Terraform Modules

#### Khái niệm và Vai trò
- Module trong Terraform là một tập hợp các file cấu hình nằm trong cùng một folder. Mỗi khi chạy lệnh trong một folder chứa cấu hình Terraform, folder đó được coi là Root Module.
- Child Module là các Module được gọi từ một Module khác để tái sử dụng. Việc sử dụng Module giúp tuân thủ nguyên lý DRY (Don't Repeat Yourself), tránh việc sao chép mã nguồn hạ tầng nhiều lần.
- Module giúp đóng gói các tài nguyên có liên quan với nhau thành một khối chức năng logic. Ví dụ: Ta có thể tạo một Module để dựng một cụm máy chủ web hoàn chỉnh bao gồm Load Balancer, Auto Scaling Group và các Security Group liên quan.

#### Cấu trúc của một Module chuẩn
Một Module thường được tổ chức trong một folder riêng biệt với cấu trúc file cơ bản như sau:
- `main.tf`: Chứa các khai báo tài nguyên chính của Module.
- `variables.tf`: Khai báo các Input Variables để người dùng truyền tham số vào khi gọi Module.
- `outputs.tf`: Khai báo các Output Values để xuất ra các thông số quan trọng sau khi tài nguyên được tạo, giúp các cấu hình khác có thể sử dụng lại.
- `providers.tf`: Định nghĩa các Provider cần thiết cho Module (nếu có).

#### Truyền tham số và xuất kết quả
- **Input Variables**: Hoạt động giống như đối số đầu vào của hàm. Ta có thể định nghĩa kiểu dữ liệu, giá trị mặc định và các quy tắc kiểm tra tính hợp lệ cho biến.
- **Output Values**: Hoạt động như giá trị trả về của hàm. Chúng cho phép các phần khác của hạ tầng truy cập vào các thuộc tính của tài nguyên bên trong Module sau khi triển khai.
- **Locals**: Biến cục bộ được định nghĩa ngay trong Module để tính toán hoặc rút gọn các biểu thức lặp đi lặp lại.

#### Nguồn khai báo Module (Module Sources)
Terraform hỗ trợ lấy mã nguồn của Module từ nhiều nguồn khác nhau thông qua thuộc tính `source`:
- **Local Paths**: Đường dẫn tương đối trong cùng dự án (ví dụ: `source = "./modules/network"`).
- **Terraform Registry**: Kho chứa Module công khai hoặc nội bộ của HashiCorp.
- **GitHub/Git**: Tải trực tiếp từ các kho lưu trữ Git (ví dụ: `source = "git::https://example.com/vpc.git"`).
- **S3 Buckets**: Lưu trữ và tải Module từ dịch vụ lưu trữ AWS S3.

---

### 2. State trong Terraform

#### Cơ chế hoạt động của State
- State là một file cơ sở dữ liệu lưu dưới dạng JSON (mặc định là `terraform.tfstate`), lưu trữ toàn bộ trạng thái thực tế của các tài nguyên mà Terraform quản lý.
- Khi chạy lệnh, Terraform sẽ thực hiện các bước:
  1. Đọc mã nguồn cấu hình để xác định trạng thái mong muốn.
  2. Đọc file State hiện tại để biết những gì đã được tạo ra trước đó.
  3. Truy vấn trực tiếp các API của Provider để cập nhật thông tin thực tế mới nhất của tài nguyên.
  4. Lập kế hoạch thay đổi và cập nhật lại file State sau khi áp dụng cấu hình thành công.

#### Lệnh quản lý State thông dụng
Tuyệt đối hạn chế chỉnh sửa trực tiếp file State bằng tay vì rất dễ gây hỏng cấu trúc dữ liệu. Thay vào đó, sử dụng các lệnh CLI an toàn:
- `terraform state list`: Liệt kê tất cả các tài nguyên đang được theo dõi trong file State.
- `terraform state show <resource>`: Xem thông tin chi tiết của một tài nguyên cụ thể lưu trong State.
- `terraform state mv <source> <destination>`: Di chuyển hoặc đổi tên tài nguyên trong State mà không làm ảnh hưởng đến tài nguyên thực tế.
- `terraform state rm <resource>`: Gỡ bỏ quyền quản lý một tài nguyên ra khỏi State của Terraform (tài nguyên thực tế trên Cloud vẫn tồn tại).

#### Lưu ý bảo mật đối với file State
- File State lưu trữ mọi thông tin cấu hình dưới dạng plain text, bao gồm cả các thông tin nhạy cảm như mật khẩu cơ sở dữ liệu, private key, API token.
- Do đó, tuyệt đối không được đưa file State lên Git hoặc các hệ thống quản lý mã nguồn công khai. File State cần được lưu trữ ở những nơi được mã hóa an toàn và kiểm soát quyền truy cập chặt chẽ.

---

### 3. Remote Backend

#### Tại sao cần Remote Backend?
- Khi làm việc một mình, file State lưu trên máy cá nhân là đủ. Tuy nhiên, khi làm việc nhóm, nhiều người cùng chạy Terraform sẽ dẫn đến việc mất đồng bộ file State hoặc vô tình đè lên cấu hình của nhau.
- Remote Backend giải quyết vấn đề này bằng cách lưu trữ file State tập trung trên một dịch vụ lưu trữ đám mây.
- Hỗ trợ mã hóa dữ liệu khi truyền tải và khi lưu trữ để bảo vệ các thông tin nhạy cảm.

#### Cấu hình S3 Backend và DynamoDB
- **AWS S3**: Được sử dụng để lưu trữ file State từ xa với tính năng phân quyền và bật versioning để có thể khôi phục lại các phiên bản State cũ nếu xảy ra lỗi.
- **DynamoDB Table**: Được sử dụng để tạo cơ chế Lock. Khi một thành viên chạy lệnh áp dụng thay đổi, Terraform sẽ tạo một bản ghi lock trong DynamoDB. Nếu thành viên khác cố gắng chạy lệnh cùng lúc, Terraform sẽ từ chối thực thi cho đến khi tiến trình trước đó hoàn thành và giải phóng lock. Điều này giúp ngăn chặn hoàn toàn tình trạng race condition.

---

## Day 2: Terraform Workspace, Dependency Graph & Remote State

### 1. Terraform Workspaces

#### Cơ chế hoạt động của Workspace
- Workspace cho phép tách biệt các file State khác nhau trên cùng một folder cấu hình duy nhất. Mặc định khi khởi tạo dự án, ta sẽ ở workspace có tên là `default`.
- Khi tạo một workspace mới, Terraform tạo ra một phân vùng State độc lập. Điều này giúp triển khai các môi trường khác nhau như Dev, Staging mà không cần nhân bản mã nguồn sang nhiều folder khác nhau.
- Đối với Local State, các State của workspace được lưu trong folder `.terraform.tfstate.d/`. Đối với Remote Backend, các file State của từng workspace sẽ được lưu dưới các đường dẫn key khác nhau trên S3.

#### Các lệnh quản lý Workspace
- `terraform workspace list`: Liệt kê danh sách các workspace đang tồn tại trong dự án.
- `terraform workspace new <name>`: Tạo mới một workspace với tên chỉ định.
- `terraform workspace select <name>`: Chuyển đổi sang sử dụng workspace mong muốn.
- `terraform workspace show`: Hiển thị tên workspace hiện tại đang được kích hoạt.
- `terraform workspace delete <name>`: Xóa một workspace không còn sử dụng (chỉ xóa được khi không ở trong chính workspace đó).

#### Ứng dụng biến Workspace trong cấu hình
Ta có thể sử dụng biến môi trường nội bộ `terraform.workspace` để tự động hóa việc đặt tên tài nguyên hoặc lựa chọn các thông số cấu hình khác nhau cho từng môi trường:
- Sử dụng cấu trúc map để chọn giá trị cấu hình tương ứng với từng workspace hoạt động.
- Giúp tinh chỉnh số lượng tài nguyên hoặc cấu hình tài nguyên nhỏ hơn cho môi trường Dev và lớn hơn cho môi trường Staging.

---

### 2. Dependency Graph và Dependency Lock File

#### Dependency Graph
- Terraform là một công cụ khai báo (declarative tool), nghĩa là ta chỉ cần khai báo trạng thái mong muốn của hạ tầng, còn Terraform sẽ tự tính toán các bước thực hiện.
- Để làm được điều này, Terraform phân tích toàn bộ mã nguồn cấu hình để xây dựng một sơ đồ phụ thuộc dưới dạng đồ thị có hướng không chu trình (Directed Acyclic Graph - DAG).
- Nhờ đồ thị này, Terraform xác định được thứ tự tạo tài nguyên chuẩn xác và có khả năng chạy song song nhiều tài nguyên không phụ thuộc nhau để tăng tốc độ triển khai hạ tầng.

#### Phân loại Dependency trong cấu hình
- **Implicit Dependency**: Sự phụ thuộc ngầm định được thiết lập khi một tài nguyên tham chiếu đến một thuộc tính của tài nguyên khác. Terraform sẽ tự động nhận diện mối quan hệ này và tạo tài nguyên bị tham chiếu trước.
- **Explicit Dependency**: Sự phụ thuộc tường minh được định nghĩa thủ công thông qua tham số `depends_on`. Bạn chỉ nên dùng tham số này khi có những mối liên hệ logic ẩn giữa các tài nguyên mà Terraform không thể tự phân tích qua việc tham chiếu thuộc tính thông thường.

#### Dependency Lock File
- File `.terraform.lock.hcl` được sinh ra tự động khi chạy lệnh khởi tạo.
- Nhiệm vụ của file này là ghi nhận chính xác phiên bản của các Provider plugin đã được tải về cùng với mã băm checksum tương ứng.
- File lock này cần được commit lên Git để đảm bảo rằng khi một thành viên khác chạy lệnh khởi tạo trên máy của họ, hệ thống sẽ tải chính xác phiên bản Provider đó, tránh các lỗi phát sinh do sai lệch phiên bản.

---

### 3. Data Source `terraform_remote_state`

#### Khái niệm chia nhỏ cấu hình (Decoupling)
- Trong các hệ thống lớn, việc gom tất cả hạ tầng vào một cấu hình Terraform duy nhất sẽ khiến file State cực kỳ lớn, làm chậm tốc độ chạy lệnh và tăng nguy cơ ảnh hưởng diện rộng khi xảy ra lỗi.
- Giải pháp là chia nhỏ hạ tầng thành các dự án quản lý độc lập. Ví dụ: Một dự án chuyên dựng VPC và hệ thống mạng cơ bản, một dự án độc lập chuyên quản lý các cụm máy chủ và ứng dụng.

#### Đọc State của dự án khác qua terraform_remote_state
- Khi chia nhỏ hạ tầng, dự án ứng dụng thường cần các thông tin từ dự án mạng như Subnet ID hoặc Security Group ID để gắn tài nguyên vào.
- Data Source `terraform_remote_state` cho phép dự án ứng dụng kết nối trực tiếp đến Remote Backend lưu trữ State của dự án mạng và truy xuất các giá trị được xuất ra trong block `output` của dự án mạng đó.
- Dữ liệu trả về ở dạng read-only, đảm bảo dự án ứng dụng chỉ đọc thông tin chứ không thể làm thay đổi hay làm hỏng file State của dự án mạng.
