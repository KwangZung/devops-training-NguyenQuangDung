# Task Submission Template

> Mỗi task = 1 thư mục con + 1 PR/MR riêng. Copy template này vào `README.md` của task.

## Task: `Day 8 - Terraform`

- **Intern**: `Nguyễn Quang Dũng`
- **Phase / Week / Day**: `Phase 1 / Week 2 / Day 8`
- **Branch**: `phase-1/week-2/day-8-terraform`
- **Submitted at**: `2026-06-29 00:11` (timezone +07)
- **Time spent**: `6h`

## 1. Mục tiêu
Tóm tắt yêu cầu task trong 2–3 dòng.

## 2. Cách chạy
**Part B: Local-only (Thử nghiệm Terraform căn bản)**
```bash
cd 1-local
terraform init
terraform plan
terraform apply
# Đổi length = 2 thành 3 trong main.tf
terraform plan
terraform apply
terraform destroy -auto-approve
```

## 3. Kết quả
**Part B: Local-only**
- Toàn bộ log hiển thị quá trình chạy đã được lưu tại: [1-local-transcript.log](./1-local/1-local-transcript.log).
- Ảnh chụp màn hình minh chứng:
  - ![Terraform Plan](./screenshots/part_b_plan.png)
  - ![Terraform Apply](./screenshots/part_b_apply.png)
  Khi thay đổi `length = 2` thành `length = 3`:
  - ![Terraform Plan Length 3](./screenshots/part_b_length_3_plan.png)

## 4. Khó khăn & cách giải quyết
- **Lỗi cài đặt Terraform qua Snap**: Khi chạy lệnh cài đặt Terraform bằng snap trên WSL bị báo lỗi cảnh báo an toàn do thiếu quyền truy cập hệ thống.
  - Cách khắc phục: Thêm cờ `--classic` vào cuối câu lệnh cài đặt để xác nhận cấp quyền (`sudo snap install terraform --classic`).
- Vấn đề 2 → cách fix.

## 5. Reference
- Đã đọc gì để làm task này (link cụ thể, không vague).

## 6. Self-check
- [ ] Code chạy được trên máy sạch.
- [ ] README có hướng dẫn run lại.
- [ ] Không hard-code secret.
- [ ] Commit message theo Conventional Commits.
- [ ] Đã review lại code 1 lượt.