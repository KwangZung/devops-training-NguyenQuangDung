# Track C — MLOps / Security (DevSecOps)

## Đối tượng
- **MLOps**: intern thiên về ML, muốn làm pipeline train/serve model.
- **Security**: intern có nền pentest/CTF, muốn vào hướng DevSecOps / cloud security.

## Roadmap

| Tuần | MLOps lane | Security lane |
|------|-----------|---------------|
| 5 | MLflow + DVC + experiment tracking | SAST/DAST/SCA trong pipeline |
| 6 | Serve model (KServe / BentoML / FastAPI) | Container & k8s hardening (PSA, OPA) |
| 7 | Training pipeline (Argo Workflows) | Cloud security (GuardDuty, SecHub, IAM Access Analyzer) |
| 8–9 | Capstone | Capstone |

## Tài liệu nên đọc

### MLOps
- [Made With ML](https://madewithml.com/) — free.
- [MLflow docs](https://mlflow.org/docs/latest/index.html)
- [Designing ML Systems — Chip Huyen](https://www.amazon.com/Designing-Machine-Learning-Systems-Production-Ready/) — đọc Ch.1, 7, 10.
- [DVC docs](https://dvc.org/doc)

### Security
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [NIST SP 800-190 Container Security](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [HashiCorp Vault tutorials](https://developer.hashicorp.com/vault/tutorials)

## Week-by-week chi tiết

### Week 5
**MLOps**:
- MLflow tracking server, log experiment 1 model (sklearn / pytorch).
- DVC versioning dataset.
- Mini lab: train 3 model variant, compare metrics.

**Security**:
- Setup pipeline với SAST (semgrep), DAST (zap), SCA (snyk/grype).
- Đo gate fail: HIGH/CRITICAL CVE.

### Week 6
**MLOps**:
- Serve model với KServe trên k8s.
- Canary deploy 2 phiên bản model.
- Đo latency + RPS bằng `vegeta` / `locust`.

**Security**:
- Pod Security Admission baseline/restricted.
- OPA Gatekeeper: deny privileged pod, require runAsNonRoot, deny `:latest` tag.
- Trivy + cosign trong CI; gate ArgoCD bằng admission.

### Week 7
**MLOps**:
- Argo Workflows pipeline: data prep → train → eval → deploy.
- Trigger từ event (DVC pipeline update).

**Security**:
- Bật GuardDuty + SecurityHub + Access Analyzer trên 1 account.
- Triage 5 finding mẫu, viết action plan.
- Threat model 1 web app (STRIDE).
