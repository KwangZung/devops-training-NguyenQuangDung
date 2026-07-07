CYAN='\033[1;36m'
NC='\033[0m'
run_cmd() {
    echo -e "\n${CYAN}➜ $@${NC}"
    "$@"
}

# --------------------------------

echo 'apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80' > minimal-ingress.yaml

# Khởi tạo Ingress
run_cmd kubectl apply -f minimal-ingress.yaml

# Kiểm tra Ingress đã được cấp Address (IP/Host) chưa
run_cmd kubectl get ingress minimal-ingress

# Xem chi tiết các luật định tuyến bên trong Ingress
run_cmd kubectl describe ingress minimal-ingress