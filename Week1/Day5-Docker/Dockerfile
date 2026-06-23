# Stage 1: Builder
# Dùng node:20 để chứa các công cụ build nếu cần
FROM node:20 AS builder

# Thiết lập thư mục làm việc
WORKDIR /app

# Copy mã nguồn vào thư mục làm việc
COPY app/server.js ./app/server.js

# Stage 2: Runtime
# Dùng bản alpine nhỏ gọn để chạy ứng dụng giúp giảm dung lượng image
FROM node:20-alpine AS runtime

# Gắn các thông tin nhãn mác
LABEL org.opencontainers.image.title="Day 5 Demo App" \
      org.opencontainers.image.description="A simple Node.js web app for Docker practice" \
      org.opencontainers.image.version="1.0.0"

# Thiết lập thư mục làm việc
WORKDIR /app

# Copy mã nguồn đã chuẩn bị từ stage builder sang
COPY --from=builder /app/app/server.js ./app/server.js

# Phân quyền sở hữu thư mục cho user node
RUN chown -R node:node /app

# Chuyển từ quyền root mặc định sang quyền non-root user
USER node

# Khai báo port ứng dụng sử dụng
EXPOSE 3000

# Thêm Healthcheck để giám sát trạng thái container
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Lệnh khởi động ứng dụng
CMD ["node", "app/server.js"]
