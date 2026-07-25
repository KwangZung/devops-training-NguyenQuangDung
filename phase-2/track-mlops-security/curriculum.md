# Giáo trình tự học Track MLOps / Security (Week 5 - Week 10)

Tài liệu này định hướng lộ trình chuyên sâu cho **Track C (MLOps & Security)** từ Week 5 đến Week 10. Giáo trình được xây dựng với các tài liệu và liên kết chính thức, giúp bạn nắm vững kiến thức về bảo mật ứng dụng (DevSecOps), bảo mật hạ tầng Cloud/K8s, và vận hành hệ thống Machine Learning (MLOps).

---

## 🗺️ Hướng đi tổng quan (Roadmap Week 5 - Week 10)
- **Week 5**: Ứng dụng DevSecOps trong CI/CD Pipeline (SAST, DAST, SCA, Secret Scanning)
- **Week 6**: Kubernetes Security & Container Hardening (Falco, OPA/Gatekeeper, Pod Security)
- **Week 7**: Cloud Security & Threat Modeling (AWS GuardDuty, SecurityHub, STRIDE)
- **Week 8**: MLOps Foundation (Quản lý Data/Model với DVC, MLflow)
- **Week 9**: MLOps Model Serving & Pipelines (KServe, BentoML, Argo Workflows)
- **Week 10**: Capstone Project (Tích hợp DevSecOps & MLOps thành một hệ thống hoàn chỉnh)

---

## 🛡️ Week 5: DevSecOps CI/CD Pipeline
*Tích hợp kiểm tra bảo mật tự động vào quy trình phát triển phần mềm (Shift-Left Security).*

### Day 1: SCA (Software Composition Analysis)
*Kiểm tra và quản lý các lỗ hổng từ thư viện/dependencies mã nguồn mở.*
- **Khái niệm SCA**: [What is Software Composition Analysis?](https://owasp.org/www-community/Component_Analysis)
- **Sử dụng Snyk cho SCA**: [Snyk Open Source Docs](https://docs.snyk.io/products/snyk-open-source)
- **OWASP Dependency-Check**: [Dependency-Check Documentation](https://jeremylong.github.io/DependencyCheck/)
- 🎥 [DevSecOps with Snyk | TechWorld with Nana](https://www.youtube.com/results?search_query=Snyk+DevSecOps+Nana)

### Day 2: SAST (Static Application Security Testing)
*Quét mã nguồn tĩnh để phát hiện các lỗi bảo mật trước khi build/compile.*
- **Khái niệm SAST**: [What is SAST?](https://owasp.org/www-community/Source_Code_Analysis_Tools)
- **SonarQube cho Code Quality & Security**: [SonarQube Documentation](https://docs.sonarqube.org/latest/)
- **Semgrep (Công cụ SAST hiện đại)**: [Semgrep Docs](https://semgrep.dev/docs/)
- 🎥 [SonarQube Tutorial | TechWorld with Nana](https://www.youtube.com/watch?v=RJBjH8E8qD8)

### Day 3: DAST (Dynamic Application Security Testing)
*Tấn công và kiểm tra ứng dụng khi đang chạy (Runtime) để tìm lỗ hổng.*
- **Khái niệm DAST**: [What is DAST?](https://owasp.org/www-community/Vulnerability_Scanning_Tools)
- **Sử dụng OWASP ZAP**: [ZAP Getting Started Guide](https://www.zaproxy.org/getting-started/)
- 🎥 [OWASP ZAP Crash Course](https://www.youtube.com/results?search_query=OWASP+ZAP+Crash+Course)

### Day 4: Secret Scanning & Image Security
*Ngăn chặn lộ lọt thông tin nhạy cảm và bảo vệ Container Image.*
- **Quét Secret với Gitleaks**: [Gitleaks Repository](https://github.com/gitleaks/gitleaks)
- **Quét Image với Trivy (CI Integration)**: [Trivy in CI/CD](https://aquasecurity.github.io/trivy/latest/tutorials/integration/ci/)
- 🎥 [Prevent Secrets in Code with Gitleaks](https://www.youtube.com/results?search_query=Gitleaks+tutorial)

### Day 5: Xây dựng Full DevSecOps Pipeline
*Tích hợp tất cả công cụ trên vào GitLab CI hoặc GitHub Actions.*
- **GitLab DevSecOps**: [GitLab Secure Documentation](https://docs.gitlab.com/ee/user/application_security/)
- **GitHub Advanced Security**: [GitHub Security Features](https://docs.github.com/en/code-security)
- 🎥 [Building a DevSecOps Pipeline | AWS & GitLab](https://www.youtube.com/results?search_query=Building+DevSecOps+Pipeline)

**Tiêu chuẩn Weekend Week 5**: Lab xây dựng 1 pipeline hoàn chỉnh (SAST -> SCA -> Image Scan -> DAST) trên repo demo.

---

## 🔐 Week 6: Kubernetes Security & Container Hardening
*Bảo mật hệ thống k8s từ lớp container đến lớp runtime policy.*

### Day 1: Container Hardening
*Giảm thiểu bề mặt tấn công của container.*
- **Distroless Images**: [Google Distroless](https://github.com/GoogleContainerTools/distroless)
- **Rootless Containers**: [Rootless Docker](https://docs.docker.com/engine/security/rootless/)
- **Docker Bench for Security**: [Docker Bench](https://github.com/docker/docker-bench-security)

### Day 2: Pod Security & Isolation
*Kiểm soát quyền của Pod và cô lập mạng lưới.*
- **Pod Security Admission**: [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- **Network Policies (Ôn tập sâu)**: [Cilium / Calico Network Policies](https://docs.cilium.io/en/stable/security/policy/)

### Day 3: Policy as Code (OPA & Gatekeeper)
*Quản lý chính sách bảo mật tự động trên K8s Cluster.*
- **Open Policy Agent (OPA)**: [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- **Gatekeeper (OPA cho K8s)**: [Gatekeeper Docs](https://open-policy-agent.github.io/gatekeeper/website/docs/)
- 🎥 [Kubernetes Policy Management with OPA Gatekeeper](https://www.youtube.com/results?search_query=Kubernetes+OPA+Gatekeeper)

### Day 4 & Day 5: Runtime Security với Falco
*Phát hiện xâm nhập và hành vi bất thường theo thời gian thực.*
- **Falco Overview**: [Falco Documentation](https://falco.org/docs/)
- **Viết Falco Rules**: [Falco Rules](https://falco.org/docs/rules/)
- 🎥 [Runtime Security with Falco](https://www.youtube.com/results?search_query=Runtime+Security+Falco)

**Tiêu chuẩn Weekend Week 6**: Setup Falco và OPA Gatekeeper trên cluster, viết policy cấm container chạy quyền root.

---

## ☁️ Week 7: Cloud Security & Threat Modeling
*Đánh giá rủi ro và bảo vệ hạ tầng trên nền tảng đám mây.*

### Day 1 & Day 2: Threat Modeling
*Nhận diện mối đe dọa từ khâu thiết kế.*
- **STRIDE Framework**: [STRIDE Threat Model](https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- **OWASP Threat Dragon**: [Threat Dragon](https://owasp.org/www-project-threat-dragon/)
- 🎥 [Threat Modeling in 10 Minutes](https://www.youtube.com/results?search_query=Threat+Modeling+STRIDE)

### Day 3 & Day 4: AWS Security Services
*Bảo mật tài khoản và hệ thống trên AWS.*
- **GuardDuty (Threat Detection)**: [Amazon GuardDuty](https://aws.amazon.com/guardduty/)
- **SecurityHub (Posture Management)**: [AWS Security Hub](https://aws.amazon.com/security-hub/)
- **IAM Access Analyzer**: [Access Analyzer Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)

### Day 5: Incident Response in Cloud
*Phản hồi và xử lý sự cố rò rỉ.*
- **AWS Incident Response Guide**: [AWS IR Guide](https://docs.aws.amazon.com/whitepapers/latest/aws-security-incident-response-guide/welcome.html)

**Tiêu chuẩn Weekend Week 7**: Vẽ sơ đồ Threat Modeling cho ứng dụng 3-tier và bật GuardDuty.

---

## 🧠 Week 8: MLOps Foundation (Data & Experiment Tracking)
*Quản lý vòng đời dữ liệu và mô hình Machine Learning.*

### Day 1 & Day 2: Data Version Control (DVC)
*Git cho Dữ liệu.*
- **Khái niệm MLOps**: [MLOps Continuous Delivery](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)
- **DVC Overview**: [DVC Documentation](https://dvc.org/doc)
- 🎥 [Data Version Control (DVC) Tutorial](https://www.youtube.com/results?search_query=DVC+Tutorial+MLOps)

### Day 3 & Day 4: MLflow Tracking & Registry
*Theo dõi kết quả training và lưu trữ model.*
- **MLflow Tracking**: [MLflow Tracking Docs](https://mlflow.org/docs/latest/tracking.html)
- **MLflow Model Registry**: [Model Registry Docs](https://mlflow.org/docs/latest/model-registry.html)
- 🎥 [MLflow in 15 Minutes](https://www.youtube.com/results?search_query=MLflow+Tutorial)

### Day 5: Feature Store Basics
- **Feast Feature Store**: [Feast Documentation](https://docs.feast.dev/)

**Tiêu chuẩn Weekend Week 8**: Train một model Python đơn giản, version data bằng DVC (lưu S3) và track metrics bằng MLflow.

---

## 🚀 Week 9: MLOps Serving & Pipelines
*Triển khai Model lên Kubernetes và tự động hóa quy trình training.*

### Day 1 & Day 2: Model Serving (BentoML & KServe)
*Đóng gói model thành API chạy trên Kubernetes.*
- **BentoML Overview**: [BentoML Docs](https://docs.bentoml.org/en/latest/)
- **KServe (Serverless ML)**: [KServe Documentation](https://kserve.github.io/website/)
- 🎥 [Model Serving with KServe](https://www.youtube.com/results?search_query=KServe+Model+Serving)

### Day 3 & Day 4: ML Pipelines (Argo Workflows)
*Tạo quy trình tự động Train -> Eval -> Deploy.*
- **Argo Workflows Basics**: [Argo Workflows Docs](https://argoproj.github.io/argo-workflows/)
- **Kubeflow Pipelines (Tổng quan)**: [Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/v2/)
- 🎥 [Argo Workflows for Machine Learning](https://www.youtube.com/results?search_query=Argo+Workflows+Machine+Learning)

### Day 5: Tích hợp DevSecOps vào ML Pipeline
*Quét lỗ hổng trong container chứa Model (AI/ML Security).*
- **Bảo mật ML Models**: [OWASP Top 10 for ML](https://mltop10.info/)

**Tiêu chuẩn Weekend Week 9**: Viết Argo Workflow để tự động chạy DVC pull data, gọi script MLflow train model và build container image (có tích hợp Trivy scan).

---

## 🎓 Week 10: Capstone Project (MLSecOps)
*Bài tập lớn cuối khoá kết hợp giữa MLOps và Security.*

- **Mục tiêu**: Xây dựng một End-to-End ML Pipeline trên Kubernetes có tính năng tự động (Trigger khi code/data thay đổi), và tích hợp đầy đủ công cụ phân tích bảo mật (SCA, SAST trong CI) cùng Runtime Security (OPA, Falco).
- **Day 1 - Day 2**: System Design & Architecture (Vẽ sơ đồ luồng đi và Threat Model).
- **Day 3 - Day 4**: Setup Infrastructure (Terraform/ArgoCD) và CI/CD DevSecOps.
- **Day 5**: Tích hợp MLflow, Argo Workflows và KServe.
- **Weekend**: Viết báo cáo, Readme, làm slide và chuẩn bị bảo vệ trước Mentor.
