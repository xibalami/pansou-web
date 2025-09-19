#!/bin/sh
set -e

# 后端固定内网 8888；Render 会把外网 $PORT（默认 10000）转进来
export PANSOU_PORT=${PANSOU_PORT:-8888}
export PANSOU_HOST=${PANSOU_HOST:-127.0.0.1}
export DOMAIN=${DOMAIN:-localhost}
FRONT_PORT="${PORT:-80}"

echo "正在启动PanSou服务，配置信息如下："
echo "- 后端地址: ${PANSOU_HOST}:${PANSOU_PORT}"
echo "- 对外端口: ${FRONT_PORT}"
echo "- 域名: ${DOMAIN}"
echo "- 前端目录: /app/frontend/dist"

mkdir -p /app/data /app/logs /var/log/nginx

# 仅一个 server，监听 $PORT；TLS 由 Render 终止，容器内不再监听 443/做 80->443 跳转
cat > /etc/nginx/conf.d/default.conf << EOF
server {
    listen ${FRONT_PORT};
    server_name ${DOMAIN};

    client_max_body_size 50M;
    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;

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

    location = /api/search {
        proxy_pass http://${PANSOU_HOST}:${PANSOU_PORT}/api/search;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Referer \$http_referer;
        proxy_connect_timeout 15s;
        proxy_read_timeout 60s;
        proxy_send_timeout 15s;
        proxy_buffering off;
    }

    location /api/ {
        proxy_pass http://${PANSOU_HOST}:${PANSOU_PORT}/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Referer \$http_referer;
        proxy_buffering off;
    }

    # 静态资源缓存
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

    location ~* \.html$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
}
EOF

echo "Nginx配置已生成"

# 启动后端：显式固定 8888，并屏蔽 PORT 影响（只对 ./pansou 生效）
echo "启动PanSou后端服务..."
cd /app
PORT= \
PANSOU_HOST="${PANSOU_HOST}" \
PANSOU_PORT="${PANSOU_PORT}" \
DOMAIN="${DOMAIN}" \
./pansou > /app/logs/pansou.log 2>&1 &

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

echo "启动Nginx服务..."
nginx -t
exec nginx -g "daemon off;"
