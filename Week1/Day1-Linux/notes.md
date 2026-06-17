1. `ls`: liệt kê các file hoặc thư mục con nằm trong thư mục hiện tại hoặc được chỉ định
2. `cd`: di chuyển đến các thư mục khác
3. `pwd`: in ra đường dẫn tuyệt đối của thư mục hiện tại 
4. `mkdir`: tạo thư mục mới
5. `rm`: xóa file hoặc thư mục
6. `cp`: copy file hoặc thư mục từ thư mục này sang thư mục khác
7. `mv`: đổi tên hoặc di chuyển file hoặc thư mục
8. `touch`: tạo file mới hoặc cập nhật thời gian sửa đổi gần nhất
9. `cat`: in toàn bộ nội dung file hoặc in nối nội dung các file
10. `less`: in nội dung của file dưới dạng trang
11. `head`: in ra một số dòng đầu tiên của file
12. `tail`: in ra một số dòng cuối cùng của file
13. `grep`: tìm các dòng chứa văn bản nào đó trong file và in ra hoặc đếm số dòng đó
14. `find`: tìm file hoặc thư mục theo tên, định dạng, kích thước,...
15. `xargs`: chuyển đầu ra của lệnh trước trong pipeline ("|") thành tham số cho lệnh phía sau
16. `awk`: xử lý file, in ra dữ liệu theo dạng dòng và cột
17. `sed`: tìm kiếm hoặc chỉnh sửa nội dung trong file, có thể chỉ in ra nội dung thay đổi hoặc sửa luôn file gốc
18. `sort`: in ra nội dung của file khi đã được sắp xếp các dòng theo thứ tự chữ cái hoặc theo số 
19. `uniq`: phát hiện các dòng trùng lặp đứng liền kề nhau trong file, rồi lọc bỏ hoặc đếm số dòng đó, thường kết hợp với lệnh sort
20. `wc`: đếm số dòng, số từ, số ký tự trong file
21. `tee`: nhận đầu vào rồi vừa in ra màn hình, vừa lưu vào các file
22. `ps`: in ra các tiến trình đang chạy trên máy trong session hiện tại, với lựa chọn -ef để hiển thị toàn bộ các tiến trình
23. `top`: hiển thị thông tin về tài nguyên hệ thống và các tiến trình đang chạy theo thời gian thực
24. `htop`:  hiển thị thông tin về tài nguyên hệ thống và các tiến trình đang chạy theo thời gian thực, dưới dạng trực quan hơn lệnh top, có sẵn các phím tắt giúp dễ dàng thao tác
25. `kill`: buộc dừng tiến trình đang chạy
26. `nice`: thiết lập độ ưu tiên sử dụng CPU cho các lệnh trước khi khởi chạy, giá trị càng lớn thì độ ưu tiên càng thấp
27. `df`: hiển thị thông tin và dung lượng lưu trữ của các ổ đĩa
28. `du`: hiển thị thông tin về các thư mục con của thư mục hiện tại đang chiếm dung lượng bao nhiêu trong ổ đĩa
29. `free`: hiển thị dung lượng và tình trạng sử dụng RAM và bộ nhớ ảo (Swap)
30. `uptime`: hiển thị thời gian hệ thống hoạt động liên tục, số người dùng và độ tải CPU
32. `who`: hiển thị thông tin các người dùng hiện đang đăng nhập vào hệ thống
33. `chmod`: thay đổi quyền read, write, execute của file hoặc thư mục
34. `chown`: thay đổi chủ sở hữu của file hoặc thư mục
35. `umask`: giới hạn quyền truy cập mặc định với các file hoặc thư mục mới được tạo
36. `tar`: đóng gói các file hoặc thư mục thành file .tar hoặc nén file .tar lại, hoặc giải nén thành file .tar
37. `gzip`: nén file thành định dạng .gz, giải nén file .gz
38. `zip`: nén toàn bộ file, thư mục thành file .zip
39. `unzip`: giải nén file .zip
40. `ssh`: kết nối với máy khác từ xa qua giao thức SSH
41. `scp`: sao chép file từ máy hiện tại sang máy đang được kết nối bằng SSH hoặc ngược lại
42. `rsync`: đồng bộ file hoặc dữ liệu giữa các máy khác nhau kết nối qua giao thức SSH
43. `ln`: tạo soft link (tương tự shortcut) hoặc hard link (con trỏ trỏ đến cùng một vùng dữ liệu) cho file hoặc thư mục
44. `env`: hiển thị các biến môi trường đã được định nghĩa, hoặc định nghĩa biến môi trường dùng cho một câu lệnh duy nhất
45. `export`: định nghĩa biến môi trường từ các biến thông thường
46. `source`: thực thi toàn bộ các lệnh trong file script
47. `curl`: gửi dữ liệu và nhận phản hồi từ server
48. `wget`: tải file từ internet về máy
49. `which`: hiển thị đường dẫn đến file script của câu lệnh
50. `whereis`: hiển thị đường dẫn đến file script của câu lệnh, file thư viện và man page của câu lệnh đó   
51. `type`: xác định loại của câu lệnh
52. `history`: hiển thị danh sách các lệnh đã được sử dụng
53. `alias`: tạo tên viết tắt, tên khác cho câu lệnh khi nó quá dài hoặc phức tạp
54. `echo`: in chuỗi văn bản ra màn hình
55. `printf`: định dạng chuỗi văn bản và in ra màn hình
