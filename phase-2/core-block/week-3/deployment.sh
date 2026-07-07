CYAN='\033[1;36m'
NC='\033[0m'
run_cmd() {
    echo -e "\n${CYAN}➜ $@${NC}"
    "$@"
}

# --------------------------------
echo 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80' > nginx-deployment.yaml

run_cmd kubectl apply -f nginx-deployment.yaml
run_cmd kubectl get deployments
run_cmd kubectl rollout status deployment/nginx-deployment
run_cmd kubectl get pods

# Nâng cấp image từ 1.14.2 lên 1.16.1
run_cmd kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
# Giám sát quá trình Rolling Update
run_cmd kubectl rollout status deployment/nginx-deployment
# Xem lịch sử các bản cập nhật của Deployment này
run_cmd kubectl rollout history deployment/nginx-deployment
# Rollback về bản trước đó
run_cmd kubectl rollout undo deployment/nginx-deployment