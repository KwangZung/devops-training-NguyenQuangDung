# Giáo trình tự học IaC, Monitoring & Security gốc

Tài liệu này tổng hợp các liên kết đọc trực tiếp từ trang tài liệu chính thức của HashiCorp Terraform, Ansible, Prometheus, Grafana, Trivy... được ánh xạ theo lộ trình học tập của Week 4 để giúp bạn xây dựng nền tảng vững chắc và hiểu rõ bản chất của từng công nghệ Configuration Management, Monitoring và Security.

## Day 1: Terraform module & Remote backend
*Tái sử dụng mã nguồn và quản lý trạng thái tập trung với Remote Backend.*

- **Tổng quan Terraform Modules**: [Modules Overview](https://developer.hashicorp.com/terraform/language/modules)
- **Tạo và sử dụng Modules**: [Creating Modules](https://developer.hashicorp.com/terraform/language/modules/develop)
- **State trong Terraform**: [State](https://developer.hashicorp.com/terraform/language/state)
- **Remote Backends**: [Backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
- **S3 Backend với DynamoDB**: [S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Nana - Terraform Modules Tutorial](https://www.youtube.com/watch?v=cOACXhDqQc0)
- [TechWorld with Nana - Terraform State & Remote Backend](https://www.youtube.com/watch?v=7xngnjfIlK4)

## Day 2: Terraform workspace, dependency graph & terraform_remote_state
*Quản lý nhiều môi trường Dev, Staging và chia sẻ state giữa các dự án.*

- **Terraform Workspaces**: [Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)
- **Dependency Lock File & Graph**: [Dependency Graph](https://developer.hashicorp.com/terraform/internals/graph)
- **Data Source terraform_remote_state**: [terraform_remote_state](https://developer.hashicorp.com/terraform/language/state/remote-state-data)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Nana - Terraform Workspaces](https://www.youtube.com/watch?v=84E1c7b8mS0)
- [Anton Babenko - Terraform remote state & workspaces best practices](https://www.youtube.com/results?search_query=Terraform+Workspaces+Remote+State)

## Day 3: Ansible: inventory, playbook, role, vault
*Công cụ tự động hóa và Configuration Management đơn giản mà mạnh mẽ.*

- **Tổng quan kiến trúc Ansible**: [How Ansible Works](https://docs.ansible.com/ansible/latest/getting_started/index.html)
- **Ansible Inventory**: [How to build your inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
- **Viết Playbooks**: [Intro to playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
- **Tái sử dụng cấu hình với Roles**: [Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)
- **Bảo mật dữ liệu với Ansible Vault**: [Encrypting content with Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Nana - Ansible Tutorial for Beginners](https://www.youtube.com/watch?v=3RiVKs8GHYQ)
- [KodeKloud - Ansible Roles Explained](https://www.youtube.com/watch?v=Z_k6mN_B-9A)

## Day 4: Prometheus + Grafana + Loki
*Thiết lập hệ thống Monitoring và Observability toàn diện cho Kubernetes Cluster.*

- **Prometheus Overview**: [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- **Grafana Dashboards**: [Grafana Dashboards Docs](https://grafana.com/docs/grafana/latest/dashboards/)
- **Loki Overview**: [Loki Documentation](https://grafana.com/docs/loki/latest/)
- **kube-prometheus-stack Helm Chart**: [prometheus-community/kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- **Alertmanager**: [Alerting with Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Nana - Prometheus Monitoring Tutorial](https://www.youtube.com/watch?v=h4Sl21AKiDg)
- [TechWorld with Nana - Kubernetes Monitoring with Prometheus](https://www.youtube.com/watch?v=QoDqxm7ybLc)
- [Grafana Loki Tutorial](https://www.youtube.com/results?search_query=Grafana+Loki+Tutorial)

## Day 5: Trivy + Cosign + SBOM
*Quét lỗ hổng bảo mật, tạo SBOM và ký số Image xác thực.*

- **Trivy Documentation**: [Trivy Docs](https://aquasecurity.github.io/trivy/latest/)
- **Tạo SBOM với Syft**: [Syft by Anchore](https://github.com/anchore/syft)
- **Ký số Image với Cosign**: [Cosign Documentation](https://docs.sigstore.dev/cosign/overview/)
- **Bảo mật Supply Chain**: [SLSA Framework](https://slsa.dev/)

**🎥 Video Tutorial Khuyến nghị:**
- [TechWorld with Nana - DevSecOps with Trivy](https://www.youtube.com/results?search_query=DevSecOps+Trivy+Nana)
- [Sigstore - How to sign container images with Cosign](https://www.youtube.com/results?search_query=Cosign+Sign+Container+Image)
- [SBOM Explained in 5 Minutes](https://www.youtube.com/results?search_query=SBOM+Explained)

## Weekend: Mini capstone Core
*Tổng hợp các kiến thức đã học trong tuần để hoàn thành bài tập lớn Capstone của Phase Core.*

- **Xem yêu cầu chi tiết**: Vui lòng tham khảo file `capstone-block.md` trong folder tài liệu.

# Các video đã xem
## Ansible
- https://www.youtube.com/watch?v=1id6ERvfozo
- https://www.youtube.com/watch?v=4nL1pBgUXBc

Vault encrypted password: vaultpass123