# PanSou Web

🚀 一体化网盘资源搜索应用，基于Vue 3 + Go构建，开箱即用的Docker镜像。

## 快速开始

### 一键启动

```bash
docker run -d --name pansou -p 80:80 ghcr.io/fish2018/pansou-web
```

访问：http://localhost

### Docker Compose（推荐）

```bash
# 下载配置文件
curl -o docker-compose.yml https://raw.githubusercontent.com/fish2018/pansou-web/main/docker-compose.yml

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DOMAIN` | `localhost` | 访问域名 |
| `PANSOU_PORT` | `8888` | 后端端口 |
| `PANSOU_HOST` | `127.0.0.1` | 后端地址 |

### 自定义配置示例

```bash
docker run -d \
  --name pansou \
  -p 80:80 \
  -e DOMAIN=yourdomain.com \
  -v pansou-data:/app/data \
  ghcr.io/fish2018/pansou-web
```

## 数据持久化

```bash
# 数据目录挂载
-v /path/to/data:/app/data

# 日志目录挂载  
-v /path/to/logs:/app/logs

# SSL证书目录（可选）
-v /path/to/ssl:/app/data/ssl
```

## HTTPS 配置

将SSL证书放入数据目录的ssl子目录：

```
/app/data/ssl/
├── fullchain.pem    # 证书文件
└── privkey.pem      # 私钥文件
```

重启容器后自动启用HTTPS。

## 常用命令

```bash
# 查看运行状态
docker ps

# 查看日志
docker logs pansou

# 重启服务
docker restart pansou

# 停止服务
docker stop pansou

# 更新镜像
docker pull ghcr.io/fish2018/pansou-web && docker restart pansou
```

## 健康检查

访问 http://localhost/api/health 查看服务状态。


