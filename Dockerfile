FROM nginx:alpine

# 安装必要的运行时依赖
RUN apk add --no-cache ca-certificates tzdata

# 设置时区
ENV TZ=Asia/Shanghai

# 设置默认环境变量
ENV PANSOU_PORT=8888
ENV PANSOU_HOST=127.0.0.1

# 创建应用目录
WORKDIR /app

# 复制后端二进制文件
COPY pansou /app/
RUN chmod +x /app/pansou

# 复制前端构建产物
COPY frontend-dist /app/frontend/dist/

# 复制启动脚本
COPY start.sh /app/
RUN chmod +x /app/start.sh

# 创建必要的目录
RUN mkdir -p /app/data /app/logs /var/log/nginx

# 创建nginx配置目录
RUN mkdir -p /etc/nginx/conf.d

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/api/health || exit 1

# 暴露端口
EXPOSE 80 443

# 设置卷挂载点
VOLUME ["/app/data", "/app/logs"]

# 设置启动命令
CMD ["/app/start.sh"]