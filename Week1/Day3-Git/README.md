## Task: Day 3 - Git Advanced

- **Intern**: Nguyễn Quang Dũng
- **Phase / Week / Day**: Phase 1 / Week 1 / Day 3
- **Branch**: `phase-1/week-1/day-3-git`
- **Submitted at**: `2026-06-19 05:35` (timezone +07)
- **Time spent**: `<số giờ>`

## 1. Mục tiêu
Thực hành và làm chủ các thao tác Git nâng cao: rebase interactive, cherry-pick, resolve conflict, phục hồi commit bằng `reflog`, dò tìm commit lỗi tự động bằng `bisect`, cài đặt `pre-commit` hook. Ngoài ra, cần phân tích và so sánh các mô hình làm việc (workflow) phổ biến: Trunk-based, GitFlow, GitHub Flow.

## 2. Cách chạy
- Toàn bộ thao tác thực hành (Part A, B, C) được lưu lịch sử tại repository: **[git-lab](https://github.com/yungn/git-lab)**.
- Các báo cáo chi tiết (`history.md`, `reflog-lab.md`, `bisect.log`, `workflow-comparison.md`) được đính kèm cùng cấp với file README này.

## 3. Kết quả
- Thực hiện đầy đủ các nhánh yêu cầu trong `git-lab` với lịch sử (history) sạch.
- Resolve conflict thành công trong Part A.
- Phục hồi thành công commit bị xóa trong Part B bằng reflog.
- Dò ra commit bị lỗi chính xác bằng lệnh `git bisect` trong Part C.
- Pre-commit hook đã hoạt động chặn được trailing-whitespace trong Part D.
- Các bằng chứng ảnh chụp (screenshot) và log được đặt đầy đủ trong thư mục `./screenshots/`.

## 4. Khó khăn & cách giải quyết
- `<Ghi chú lại những khó khăn gặp phải trong quá trình làm và cách giải quyết>`

## 5. Reference
- [Pro Git book — Ch.3 Branching, Ch.7 Tools](https://git-scm.com/book/en/v2)
- [Learn Git Branching](https://learngitbranching.js.org/)
- [So you think you know Git - Scott Chacon](https://www.youtube.com/watch?v=aolI_Rz0ZqY)

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.
