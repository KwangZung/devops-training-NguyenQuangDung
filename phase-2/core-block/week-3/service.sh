CYAN='\033[1;36m'
NC='\033[0m'
run_cmd() {
    echo -e "\n${CYAN}➜ $@${NC}"
    "$@"
}

# --------------------------------
echo 'apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80' > my-service.yaml

# Khởi tạo Service
run_cmd kubectl apply -f my-service.yaml

# Xem Service đã được cấp địa chỉ IP ảo (ClusterIP) chưa
run_cmd kubectl get svc my-service

# Xem Service đã bắt thành công địa chỉ IP thật của 3 Pod chưa (Endpoints)
run_cmd kubectl get endpoints my-service
