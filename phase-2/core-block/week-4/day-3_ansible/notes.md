# Tài liệu ghi chú kiến thức Ansible - Day 3

Tài liệu này tổng hợp chi tiết các kiến thức quan trọng về Ansible dựa trên tài liệu chính thức từ HashiCorp/RedHat, phục vụ cho quá trình học tập và làm việc.

---

## 1. Tổng quan kiến trúc Ansible (How Ansible Works)
- **Mô hình Agentless (Không đại lý)**: Ansible hoạt động theo mô hình Push (đẩy cấu hình), kết nối từ máy điều khiển (Control Node) đến các máy đích (Managed Node) thông qua giao thức SSH (đối với Linux) hoặc WinRM (đối với Windows) mà không cần cài đặt bất kỳ chương trình đại lý (agent software) nào trên máy đích.
- **Control Node**: Máy chủ cài đặt Ansible, dùng để thực thi các lệnh hoặc Playbook để quản lý các máy đích.
- **Managed Node (hoặc Host)**: Các Server mục tiêu được Ansible kết nối và cấu hình.
- **Cơ chế hoạt động của module**: Khi chạy một task, Ansible sẽ biên dịch task đó thành một script Python nhỏ, gửi qua SSH sang máy đích, thực thi và tự động xóa script đó đi sau khi hoàn tất.
- **Tính đồng dạng (Idempotence)**: Ansible hoạt động theo cơ chế khai báo trạng thái mong muốn. Nếu hệ thống đã đạt trạng thái khai báo, Ansible sẽ bỏ qua và không thực hiện thay đổi nào nữa để đảm bảo tính ổn định cho hệ thống.

---

## 2. Ansible Inventory (How to build your inventory)
Inventory là file cấu hình chứa danh sách các máy đích và các tham số kết nối tương ứng mà Ansible sẽ quản lý.

- **Định dạng file**: Inventory có thể được viết dưới định dạng INI hoặc YAML. Định dạng INI phổ biến và dễ đọc hơn đối với các cấu trúc đơn giản.
- **Phân nhóm Host (Grouping)**: Ta có thể gom nhóm các Host theo chức năng hoặc vị trí môi trường. Có thể sử dụng từ khóa `:children` để tạo các nhóm lồng nhau.
- **Khai báo biến (Variables)**:
  - Biến cho từng Host (Host Variables): Khai báo trực tiếp bên cạnh Host.
  - Biến cho nhóm Host (Group Variables): Khai báo dưới khối `[ten_nhom:vars]`.
- **Phân loại Inventory**:
  - Static Inventory: Danh sách Host được ghi cứng trong file.
  - Dynamic Inventory: Danh sách Host được sinh ra tự động từ các script truy vấn thông tin API của nhà cung cấp dịch vụ đám mây (AWS, GCP, Azure, vSphere) hoặc các công cụ quản lý hạ tầng.

---

## 3. Viết Playbooks (Intro to playbooks)
Playbook là file kịch bản tự động hóa chính của Ansible, được viết bằng định dạng YAML.

- **Cấu trúc cơ bản của Playbook**:
  - Play: Khai báo nhóm Host mục tiêu (`hosts`) và quyền thực thi (`become: yes`).
  - Tasks: Danh sách tuần tự các công việc cần làm trên Host. Mỗi task sẽ gọi một module cụ thể.
- **Quy trình khai báo Task**: Mỗi task nên có tên mô tả rõ ràng (`name`) và các tham số truyền vào module tương ứng.
- **Cơ chế notify và handlers**:
  - Handlers là các task đặc biệt nằm ngoài luồng chạy tuần tự, chỉ được thực thi khi có một task khác kích hoạt (thông qua từ khóa `notify`) và task kích hoạt đó thực sự tạo ra thay đổi trạng thái hệ thống (`changed`).
  - Phù hợp nhất cho việc khởi động lại dịch vụ sau khi thay đổi file cấu hình.
- **Thu thập thông tin hệ thống (Gathering Facts)**: Ansible mặc định tự động chạy module `setup` ở đầu mỗi Play để thu thập thông tin phần cứng, hệ điều hành, địa chỉ IP của máy đích (gọi là các Fact). Ta có thể tắt tính năng này bằng cú pháp `gather_facts: no` để tăng tốc độ chạy nếu không cần dùng đến các thông số này.

---

## 4. Tái sử dụng cấu hình với Roles (Roles)
Role là cách tổ chức cấu trúc folder chuẩn hóa của Ansible giúp chia nhỏ Playbook thành các thành phần độc lập để dễ dàng tái sử dụng và chia sẻ.

- **Cấu trúc folder tiêu chuẩn của một Role**:
  - `defaults/`: Chứa các biến mặc định của Role. Các biến này có độ ưu tiên thấp nhất, rất dễ bị ghi đè.
  - `vars/`: Chứa các biến nội bộ của Role, có độ ưu tiên cao hơn và khó bị ghi đè hơn.
  - `tasks/`: Chứa danh sách các task chính thực thi cấu hình.
  - `handlers/`: Chứa các task phản hồi sự kiện (như khởi động lại dịch vụ).
  - `templates/`: Chứa các file cấu hình động sử dụng cú pháp Jinja2.
  - `files/`: Chứa các file tĩnh cần sao chép trực tiếp lên máy đích.
  - `meta/`: Định nghĩa các dependencies của Role (các Role khác cần chạy trước).
- **Cách gọi Role**: Khai báo trong khối `roles:` của Playbook chính.

---

## 5. Bảo mật dữ liệu với Ansible Vault (Ansible Vault)
Ansible Vault là tính năng mã hóa mạnh mẽ giúp bảo vệ các thông tin nhạy cảm (như mật khẩu, key, token) trong dự án Ansible.

- **Cơ chế mã hóa**: Sử dụng thuật toán AES-256 để mã hóa dữ liệu. Dữ liệu sau khi mã hóa có thể được lưu trữ an toàn trên các hệ thống quản lý phiên bản Git mà không sợ bị lộ.
- **Các phương thức mã hóa**:
  - Mã hóa toàn bộ file: `ansible-vault encrypt secrets.yml`
  - Giải mã file: `ansible-vault decrypt secrets.yml`
  - Chỉnh sửa file đã mã hóa trực tiếp: `ansible-vault edit secrets.yml`
  - Mã hóa riêng lẻ từng biến (Vault String): `ansible-vault encrypt_string 'mat_khau_bi_mat' --name 'my_secret_var'`
- **Thực thi Playbook có sử dụng Vault**:
  - Yêu cầu nhập mật khẩu thủ công khi chạy: Thêm tham số `--ask-vault-pass`.
  - Đọc mật khẩu tự động từ file (được bảo vệ quyền truy cập): Thêm tham số `--vault-password-file /duong/dan/file`.
