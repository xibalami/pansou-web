#!/bin/sh
set -e

# 环境变量默认值
export PANSOU_PORT=${PANSOU_PORT:-8888}
export PANSOU_HOST=${PANSOU_HOST:-127.0.0.1}
export DOMAIN=${DOMAIN:-localhost}

# Render 会注入 PORT（例如 10000）；本地无该变量时用 80
FRONT_PORT="${PORT:-80}"

echo "正在启动PanSou服务，配置信息如下："
echo "- 后端地址: ${PANSOU_HOST}:${PANSOU_PORT}"
echo "- 对外端口: ${FRONT_PORT}"
echo "- 域名: ${DOMAIN}"
echo "- 前端目录: /app/frontend/dist"

# 创建必要的目录
mkdir -p /app/data /app/logs /var/log/nginx

# 说明：Render 已做 TLS 终止，这里统一走 HTTP 单端口；若本地需要自签证书可另行扩展
echo "未使用容器内HTTPS（Render或反向代理会在外部终止TLS）"

# 动态生成Nginx配置（仅一个 server，监听 $FRONT_PORT）
cat > /etc/nginx/conf.d/default.conf << EOF
server {
    listen ${FRONT_PORT};
    server_name ${DOMAIN};

    client_max_body_size 50M;

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;

    # 健康检查
    location = /api/health {
        proxy_pass http://${PANSOU_HOST}:${PANSOU_PORT}/api/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout 10s;
        proxy_send_timeout 5s;
        proxy_buffering off;
    }

    # 其他API
    location /api/ {
        proxy_pass http://${PANSOU_HOST}:${PANSOU_PORT}/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
    }

    # 静态资源
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /app/frontend/dist;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
        add_header X-Content-Type-Options nosniff;
    }

    # SPA 路由
    root /app/frontend/dist;
    index index.html;
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # 防止HTML缓存
    location ~* \.html$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
}
EOF

echo "Nginx配置已生成"

# 启动后端：显式屏蔽 PORT 影响，强制用 PANSOU_PORT（默认8888）
echo "启动PanSou后端服务..."
cd /app
PORT= \
PANSOU_HOST="${PANSOU_HOST}" \
PANSOU_PORT="${PANSOU_PORT}" \
DOMAIN="${DOMAIN}" \
./pansou > /app/logs/pansou.log 2>&1 &

# 等待后端服务启动
echo "等待后端服务启动..."
for i in $(seq 1 30); do
    if curl -fsS "http://${PANSOU_HOST}:${PANSOU_PORT}/api/health" >/dev/null 2>&1; then
        echo "后端服务启动成功"
        break
    fi
    echo "等待后端服务... ($i/30)"
    sleep 1
done

if ! curl -fsS "http://${PANSOU_HOST}:${PANSOU_PORT}/api/health" >/dev/null 2>&1; then
    echo "错误: 后端服务启动失败"
    echo "--------- /app/logs/pansou.log ---------"
    cat /app/logs/pansou.log || true
    exit 1
fi

# 启动nginx（前台）
echo "启动Nginx服务..."
nginx -t
exec nginx -g "daemon off;"
