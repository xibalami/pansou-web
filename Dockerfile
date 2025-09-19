ARG PANSOU_VERSION=latest

# ===== 后端阶段：按目标架构编译 pansou，可通过 PANSOU_VERSION 固定版本 =====
FROM golang:1.21-alpine AS backend
RUN apk add --no-cache git
WORKDIR /build
ARG TARGETOS TARGETARCH
ENV CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH
# 生成 /go/bin/pansou
RUN go install github.com/fish2018/pansou@${PANSOU_VERSION}

# ===== 前端阶段：构建 dist =====
FROM node:18-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ===== 运行阶段：Nginx + 后端一体化 =====
FROM nginx:alpine AS runtime
RUN apk add --no-cache ca-certificates tzdata curl
ENV TZ=Asia/Shanghai \
    PANSOU_HOST=127.0.0.1 \
    PANSOU_PORT=8888 \
    ENABLED_PLUGINS="labi,zhizhen,shandian,duoduo,muou,wanou"
WORKDIR /app

# 拷贝产物
COPY --from=backend  /go/bin/pansou   /app/pansou
COPY --from=frontend /app/dist/       /app/frontend/dist/
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh && mkdir -p /app/data /app/logs /var/log/nginx

# 健康检查：Render 会注入 $PORT；本地无则走 80
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${PORT:-80}/api/health" || exit 1

EXPOSE 80 443
VOLUME ["/app/data", "/app/logs"]
CMD ["/app/start.sh"]
