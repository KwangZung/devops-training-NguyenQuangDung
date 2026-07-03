# Phase 1 - Theory Exam
## Part 1 - Trắc nghiệm
1. Lệnh nào tìm tất cả file `.log` lớn hơn 100MB trong `/var`?
   - A. `find /var -name "*.log" -size +100M`
   - B. `grep -r "*.log" /var | size > 100M`
   - C. `ls -lR /var | grep ".log" | awk '$5>100'`
   - D. `du -sh /var/*.log | filter`
=> Chọn A

2. `chmod 750 file` cho phép:
   - A. Owner rwx, group r-x, other không gì.
   - B. Owner rwx, group rwx, other r-x.
   - C. Owner rw-, group r--, other r--.
   - D. Owner rwx, group r--, other r-x.
=> Chọn A

3. `git reset --soft HEAD~1` làm gì?
   - A. Xoá commit cuối khỏi history và xoá thay đổi.
   - B. Bỏ commit cuối, giữ thay đổi staged.
   - C. Bỏ commit cuối, giữ thay đổi nhưng unstage.
   - D. Tạo commit mới revert lại.
=> Chọn B
