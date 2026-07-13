# Task Submission Template

> Mỗi task = 1 folder con + 1 PR/MR riêng. Copy template này vào `README.md` của task.

## Task: `Week 4: IaC nâng cao + Monitoring + Security basics: Day 1&2 - Terraform`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 2 / Week 4 / Day 1 & 2`
- **Branch**: `phase-2/week-4/day-1`
- **Submitted at**: `2026-07-11 08:40` (timezone +07)
- **Time spent**: `6h`

## 1. Mục tiêu


## 2. Cách chạy
### Terraform modules
#### Tạo 1 module có tên `k8s-app`

Module `k8s-app` được cấu trúc để đóng gói và tái sử dụng các tài nguyên Kubernetes chính, bao gồm các file sau:
- [variables.tf](modules/k8s-app/variables.tf): Khai báo các Input Variables đầu vào của Module như tên ứng dụng (`app_name`), địa chỉ image (`image`), số lượng bản sao (`replicas`), môi trường triển khai (`env`) và tên miền cấu hình (`ingress_host`).
- [main.tf](modules/k8s-app/main.tf): Cấu hình định nghĩa chi tiết các tài nguyên Kubernetes bao gồm Deployment (quản lý Pod), Service (dịch vụ phân phối traffic nội bộ) và Ingress (định tuyến traffic từ tên miền bên ngoài vào).
- [outputs.tf](modules/k8s-app/outputs.tf): Định nghĩa các giá trị trả về (Output Values) của Module bao gồm tên Service (`service_name`), đường dẫn DNS nội bộ Cluster (`service_endpoint`) và tên miền Ingress (`ingress_hostname`).

#### Triển khai module đó trên môi trường dev
Các file cấu hình:
- [main.tf](envs/dev/main.tf): Cấu hình gọi Module `k8s-app` với nguồn tương đối và truyền các giá trị biến cấu hình cụ thể cho môi trường Dev (như `app_name = "demo-app-dev"`, `replicas = 1`, `ingress_host = "dev.demo.local"`).
- [outputs.tf](envs/dev/outputs.tf): Cấu hình hiển thị các giá trị Output Values nhận về từ Module `k8s-app` sau khi triển khai môi trường Dev.

Các bước:
1. Di chuyển vào folder môi trường dev:
   ```bash
   cd envs/dev
   ```
2. Khởi tạo Terraform để chuẩn bị các Provider và Module:
   ```bash
   terraform init
   ```
3. Xem kế hoạch triển khai tài nguyên hạ tầng:
   ```bash
   terraform plan
   ```
4. Áp dụng cấu hình để tạo các tài nguyên lên Cluster:
   ```bash
   terraform apply -auto-approve=true
   ```
   ![apply success in dev](./screenshots/tf_modules-apply-complete-in-dev.png)
5. Kiểm tra lại các tài nguyên đã được tạo trên Cluster Kubernetes:
   ```bash
   kubectl get pods,svc,ingress -n default | grep "demo-app-dev"
   ```
   ![check resources in dev](./screenshots/tf-modules_check-dev-resources-in-k8s.png)
6. Kiểm tra khả năng truy cập ứng dụng qua Ingress:
   - Thực hiện port-forward service của Ingress Controller khi chưa map port ra ngoài:
     ```bash
     kubectl port-forward service/traefik 8080:80 -n kube-system
     ```
   - Chạy lệnh `curl` giả lập Header Host để kiểm tra:
     ```bash
     curl -H "Host: dev.demo.local" http://localhost:8080
     ```
     ![curl dev](./screenshots/tf-modules_curl-dev.png)
7. Dọn dẹp các tài nguyên đã triển khai:
   ```bash
   terraform destroy -auto-approve=true
   ```


#### Triển khai module đó trên môi trường stg
Các file cấu hình:
- [main.tf](envs/stg/main.tf): Cấu hình gọi Module `k8s-app` tương tự như Dev nhưng truyền các giá trị biến cấu hình đặc trưng cho môi trường Staging (như `app_name = "demo-app-stg"`, `replicas = 3`, `ingress_host = "stg.demo.local"`).
- [outputs.tf](envs/stg/outputs.tf): Cấu hình hiển thị các giá trị Output Values nhận về từ Module `k8s-app` sau khi triển khai môi trường Staging.

Các bước:
1. Di chuyển vào folder môi trường stg:
   ```bash
   cd envs/stg
   ```
2. Khởi tạo Terraform để chuẩn bị các Provider và Module:
   ```bash
   terraform init
   ```
3. Xem kế hoạch triển khai tài nguyên hạ tầng:
   ```bash
   terraform plan
   ```
4. Áp dụng cấu hình để tạo các tài nguyên lên Cluster:
   ```bash
   terraform apply -auto-approve=true
   ```
   ![apply success in stg](./screenshots/tf-modules_apply-complete-in-stg.png)
5. Kiểm tra lại các tài nguyên đã được tạo trên Cluster Kubernetes:
   ```bash
   kubectl get pods,svc,ingress -n default | grep "demo-app-stg"
   ```
   ![check resources in stg](./screenshots/tf-modules_check-stg-resoures-in-k8s.png)
6. Kiểm tra khả năng truy cập ứng dụng qua Ingress:
   - Thực hiện port-forward service của Ingress Controller khi chưa map port ra ngoài:
     ```bash
     kubectl port-forward service/traefik 8080:80 -n kube-system
     ```
   - Chạy lệnh `curl` giả lập Header Host để kiểm tra:
     ```bash
     curl -H "Host: stg.demo.local" http://localhost:8080
     ```
     ![curl stg](./screenshots/tf-modules_curl-stg.png)
7. Dọn dẹp các tài nguyên đã triển khai:
   ```bash
   terraform destroy -auto-approve=true
   ```




## 3. Kết quả

## 4. Khó khăn & cách giải quyết

Không có.

## 5. Reference
- [SpaceLift - Terraform Modules Tutorial: Why Use Them, Best Practices, and Scaling](https://www.youtube.com/watch?v=Te4ijEaUGyU)


## 6. Self-check

- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.