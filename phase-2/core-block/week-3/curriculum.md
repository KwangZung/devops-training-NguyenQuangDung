# Giáo trình tự học Kubernetes gốc (Official Documentation)

Tài liệu này tổng hợp các liên kết đọc trực tiếp từ trang tài liệu chính thức của Kubernetes (https://kubernetes.io/docs/concepts/), được ánh xạ theo lộ trình học tập của Week 3 để giúp bạn xây dựng nền tảng vững chắc và hiểu rõ bản chất của từng thành phần trong hệ thống.

## Day 1: Kiến trúc hệ thống & Khái niệm nền tảng
*Tập trung vào việc hiểu hệ thống Kubernetes được cấu tạo như thế nào trước khi chạy ứng dụng.*

- **Tổng quan Kubernetes**: [What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/)
- **Kiến trúc hệ thống (Control Plane & Nodes)**: [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- **Máy trạm vật lý/ảo (Nodes)**: [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)
- **Công cụ dòng lệnh (kubectl)**: [Command line tool (kubectl)](https://kubernetes.io/docs/reference/kubectl/)
- **Đơn vị thực thi nhỏ nhất (Pod)**: [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- **Vòng đời của Pod**: [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Sahana - Kubernetes Zero to Hero Playlist](https://www.youtube.com/playlist?list=PL8h_iS3fGq0KYUn8JfXF86pAzssaH_Frn) *(Toàn tập Kubernetes)*
- [TechWorld with Sahana - Kubernetes Architecture Explained in 15 Min](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+Architecture+Explained) *(Kiến trúc)*
- [TechWorld with Sahana - Kubernetes POD Explained in 15 Min](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+POD+Explained) *(Pod)*

## Day 2: Mở rộng quy mô & Điều hướng mạng
*Cách duy trì ứng dụng luôn chạy, tự động nâng cấp và cách để người dùng truy cập được vào ứng dụng.*

- **Quản lý vòng đời ứng dụng (Deployment)**: [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- **Kết nối mạng nội bộ (Service)**: [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- **Bộ định tuyến ngoại mạng (Ingress)**: [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- **Trình điều khiển Ingress**: [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

**🎥 Video Tutorial Khuyến nghị:**
- [Kubernetes ReplicaSets and Deployments in 20 Min | Chapter 4](https://www.youtube.com/watch?v=K5_6nDyPJz8)
- [TechWorld with Sahana - Kubernetes Services & DNS Explained](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+Services+DNS) *(Cơ chế Service & Mạng)*
- [TechWorld with Sahana - Kubernetes Ingress Explained](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+Ingress+Explained) *(Ingress & Routing)*

## Day 3: Quản lý cấu hình & Bảo mật thông tin
*Tách biệt cấu hình ra khỏi mã nguồn để ứng dụng đạt chuẩn phi trạng thái (Stateless).*

- **Quản lý cấu hình (ConfigMap)**: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- **Bảo mật dữ liệu nhạy cảm (Secret)**: [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- **Hướng dẫn inject cấu hình thành biến môi trường**: [Using ConfigMaps as environment variables](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#define-container-environment-variables-using-configmap-data)
- **Hướng dẫn gắn cấu hình thành file (Projected Volume)**: [Using Secrets as files from a pod](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Sahana - Kubernetes ConfigMap & Secret in Real World](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+ConfigMap+Secret) *(Thực hành tách cấu hình)*
- [TechWorld with Sahana - 5 Common Kubernetes Pod Errors Explained](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+Pod+Errors) *(Bonus: Khắc phục lỗi phổ biến)*

## Day 4: Quản lý lưu trữ (Storage)
*Lưu trữ dữ liệu vĩnh viễn (Persistent) cho các ứng dụng có trạng thái như Database.*

- **Tổng quan về Lưu trữ**: [Storage](https://kubernetes.io/docs/concepts/storage/)
- **Ổ đĩa hệ thống (Volumes)**: [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- **Cấp phát lưu trữ vĩnh viễn (PV & PVC)**: [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- **Lớp lưu trữ tự động (Storage Classes)**: [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Sahana - Kubernetes Storage & Volumes Explained](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+Volumes) *(Cơ chế Persistent Storage)*
- [KodeKloud - Storage in Kubernetes](https://www.youtube.com/watch?v=xOIKnK8E340) *(Minh họa PV & PVC)*

## Day 5: Phân quyền & Bảo mật mạng
*Bảo vệ Cluster khỏi các truy cập trái phép và cô lập mạng giữa các ứng dụng.*

- **Tài khoản dịch vụ (Service Accounts)**: [Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)
- **Phân quyền truy cập (RBAC)**: [Role-Based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- **Cách ly mạng (Network Policies)**: [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Sahana - Kubernetes RBAC Explained (Role, RoleBinding)](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+RBAC) *(Demo phân quyền)*
- [Ahmet Alp Balkan - Securing Kubernetes with Network Policies](https://www.youtube.com/watch?v=3gJVNGhhVCc) *(Cách ly mạng K8s)*

## Weekend: HPA, VPA & Đóng gói ứng dụng (Helm)
*Lưu ý: Horizontal Pod Autoscaler và Vertical Pod Autoscaler giúp tự động điều chỉnh tài nguyên của Pod. Helm là tiêu chuẩn công nghiệp để đóng gói và triển khai ứng dụng, đây là dự án độc lập không nằm trong tài liệu chính thức của Kubernetes.*

- **Horizontal Pod Autoscaler**: [HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- **Vertical Pod Autoscaler**: [VPA Documentation](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
- **Tài liệu chính thức của Helm**: [Helm Docs](https://helm.sh/docs/)
- **Khái niệm cơ bản về Helm Chart**: [Charts](https://helm.sh/docs/topics/charts/)

**🎥 Video Tutorial Khuyến nghị:**
- [Khoá học Kubernetes thực tế - Bài 29. Horizontal Pod Autoscaler (Tiếng Việt)](https://www.youtube.com/watch?v=Ofn942zoL7g) *(Cơ chế HPA)*
- [Kubernetes Vertical Pod Autoscaler](https://www.youtube.com/watch?v=dzsYkXo1_Tg) *(Cơ chế VPA)*
- [TechWorld with Sahana - Kubernetes Helm Charts Tutorial](https://www.youtube.com/results?search_query=TechWorld+with+Sahana+Kubernetes+Helm) *(Khái niệm & Cách dùng)*
- [VN Techies - Deploy ứng dụng với Helm (Tiếng Việt)](https://www.youtube.com/watch?v=X1fX_n2m9k0)
