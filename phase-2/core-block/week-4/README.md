# Week 4 — IaC nâng cao + Monitoring + Security basics

## Mục tiêu

- Terraform: module, remote backend, workspace, dependency.
- Ansible cơ bản cho config management.
- Stack monitoring: Prometheus + Grafana + Loki + Alertmanager.
- Security baseline: secret mgmt, image scan, SBOM.

## Lịch

| Day | Topic | Output |
|-----|-------|--------|
| 1 | Terraform module + remote backend (S3+DDB) | Module `network`, `compute` reuse cho 2 env |
| 2 | Terraform workspace, dependency graph, `terraform_remote_state` | Dev/stg cùng module, state riêng |
| 3 | Ansible: inventory, playbook, role, vault | Cài stack monitoring lên 1 VM bằng ansible |
| 4 | Prometheus + Grafana + Loki trên k8s (kube-prometheus-stack) | Stack qua Helm, dashboard preload |
| 5 | Trivy + cosign + SBOM | Scan image, sign image, verify trong CI |
| Weekend | Mini capstone Core | Xem `capstone-block.md` |

## Bài tập tiêu biểu

### Lab 1: Module Terraform
- Tạo module `modules/k8s-app/` nhận biến: image, replicas, env, ingress_host.
- Module output: helm release name, service endpoint.
- 2 root config dùng module: `envs/dev`, `envs/stg`.

### Lab 2: Ansible role nginx
- Role cài nginx + cấu hình từ template + cấp cert.
- Inventory 2 host (giả lập bằng 2 container Docker SSH).
- `ansible-playbook -i inventory site.yml --check` chạy idempotent.

### Lab 3: kube-prometheus-stack
- Cài bằng Helm.
- Expose Grafana qua ingress.
- Import dashboard ID `1860` (node-exporter full).
- Tạo PrometheusRule alert "Pod restart > 3 lần / 10 phút".

### Lab 4: Supply chain
- Scan `demo-app` image bằng `trivy image`.
- Sinh SBOM bằng `syft` → upload artifact.
- Sign image bằng `cosign` (keyless, qua GitHub OIDC).
- Verify trong workflow CD: nếu image không có signature → reject.

## Pass criteria tuần

- [ ] Module dùng được ở 2 env, state tách riêng.
- [ ] Ansible chạy lại 3 lần kết quả vẫn idempotent.
- [ ] Dashboard Grafana sống, có alert test fire được.
- [ ] CD pipeline reject image chưa sign.