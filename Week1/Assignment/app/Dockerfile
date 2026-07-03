# Giai đoạn 1: Tải và cài đặt thư viện tạm thời
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY src/ ./src/

# Giai đoạn 2: Lắp ráp bản chạy chính thức
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src

# Hạ cấp xuống nhóm người dùng thông thường để tăng tính an toàn
USER node
EXPOSE 3000
CMD ["node", "src/index.js"]