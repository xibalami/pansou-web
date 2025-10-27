# PanSou Docker 部署文档

## 📖 目录

- [快速开始](#快速开始)
- [部署方式](#部署方式)
- [环境变量配置](#环境变量配置)
- [常见配置场景](#常见配置场景)
- [数据目录说明](#数据目录说明)
- [SSL证书配置](#ssl证书配置)
- [性能调优](#性能调优)
- [故障排查](#故障排查)

---

## 🚀 快速开始

### 最简单的部署方式

```bash
# 使用 docker-compose（推荐）
docker-compose up -d

# 或使用 docker run
docker run -d \
  -p 80:80 \
  -v pansou-data:/app/data \
  ghcr.io/fish2018/spansou-web:latest
```

访问 `http://localhost` 即可使用。

---

## 📦 部署方式

### 方式一：使用 Docker Compose（推荐）

**优势：**
- ✅ 配置文件化，易于管理
- ✅ 自动包含 autoheal 容器重启机制
- ✅ 支持多容器编排
- ✅ 一键启动/停止

**步骤：**

```bash
# 1. 下载 docker-compose.yml
wget https://raw.githubusercontent.com/fish2018/spansou-web/main/docker-compose.yml

# 2. 编辑配置（可选）
vim docker-compose.yml

# 3. 启动服务
docker-compose up -d

# 4. 查看日志
docker-compose logs -f pansou

# 5. 停止服务
docker-compose down
```

### 方式二：使用 Docker Run

**适用场景：**
- 简单部署
- 快速测试
- 自定义容器编排

**基础命令：**

```bash
docker run -d \
  --name pansou-app \
  -p 80:80 \
  -p 443:443 \
  -v pansou-data:/app/data \
  --restart unless-stopped \
  ghcr.io/fish2018/spansou-web:latest
```

**完整命令（带配置）：**

```bash
docker run -d \
  --name pansou-app \
  -p 80:80 \
  -p 443:443 \
  -e DOMAIN=example.com \
  -e CACHE_PATH=/app/data/cache \
  -e LOG_PATH=/app/data/logs \
  -e HEALTH_CHECK_INTERVAL=30 \
  -e HEALTH_CHECK_TIMEOUT=10 \
  -e HEALTH_CHECK_RETRIES=3 \
  -e ENABLED_PLUGINS=labi,zhizhen,shandian,duoduo \
  -e CHANNELS=tgsearchers3,Aliyun_4K_Movies \
  -v pansou-data:/app/data \
  --restart unless-stopped \
  ghcr.io/fish2018/spansou-web:latest
```

---

## ⚙️ 环境变量配置

### 基础配置

| 变量名 | 默认值 | 说明 | 示例 |
|--------|--------|------|------|
| `DOMAIN` | `localhost` | 域名配置 | `example.com` |

**说明：**
- `DOMAIN`: 影响 SSL 证书和 Nginx 配置

### 数据目录配置

| 变量名 | 默认值 | 说明 | 用途 |
|--------|--------|------|------|
| `CACHE_PATH` | `/app/data/cache` | 缓存目录 | 存储搜索缓存、临时数据 |
| `LOG_PATH` | `/app/data/logs` | 日志目录 | 存储后端和Nginx日志 |

**目录结构：**
```
/app/data/
      ├── cache/              # 缓存数据
      │   ├── disk/          # 磁盘缓存
      │   └── qqpd_users/    # QQPD插件用户数据
      ├── logs/              # 日志文件
      │   ├── backend/       # 后端日志
      │   │   └── pansou.log
      │   └── nginx/         # Nginx日志
      │       ├── access.log
      │       └── error.log
      └── ssl/               # SSL证书
          ├── fullchain.pem
          └── privkey.pem
```

### 插件配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `ENABLED_PLUGINS` | `labi,zhizhen,shandian,...` | 启用的插件列表（逗号分隔） |

**完整默认插件列表：**
```
labi,zhizhen,shandian,duoduo,muou,wanou,hunhepan,jikepan,
panwiki,pansearch,panta,qupansou,hdr4k,pan666,susu,
thepiratebay,xuexizhinan,panyq,ouge,huban,cyg,erxiao,
miaoso,fox4k,pianku,clmao,wuji,cldi,xiaozhang,libvio,
leijing,xb6v,xys,ddys,hdmoli,yuhuage,u3c3,javdb,clxiong,
jutoushe,sdso,xiaoji,xdyh,haisou,bixin,djgou,nyaa,
xinjuc,aikanzy,qupanshe,xdpan,discourse,yunsou,qqpd
```

**自定义插件：**
```bash
# 只启用部分插件
-e ENABLED_PLUGINS=labi,zhizhen,panta,qqpd

# 禁用所有插件（只使用Telegram频道）
-e ENABLED_PLUGINS=
```

### Telegram频道配置

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `CHANNELS` | `tgsearchers3,Aliyun_4K_Movies,...` | Telegram频道列表（逗号分隔） |

**完整默认频道列表：**
```
tgsearchers3,Aliyun_4K_Movies,bdbdndn11,yunpanx,
bsbdbfjfjff,yp123pan,sbsbsnsqq,yunpanxunlei,tianyifc,
BaiduCloudDisk,txtyzy,peccxinpd,gotopan,PanjClub,
kkxlzy,baicaoZY,MCPH01,bdwpzhpd,ysxb48,jdjdn1111,
yggpan,MCPH086,zaihuayun,Q66Share,ucwpzy,shareAliyun,
alyp_1,dianyingshare,Quark_Movies,XiangxiuNBB,
ydypzyfx,ucquark,xx123pan,yingshifenxiang123,zyfb123,
tyypzhpd,tianyirigeng,cloudtianyi,hdhhd21,Lsp115,
oneonefivewpfx,qixingzhenren,taoxgzy,Channel_Shares_115,
tyysypzypd,vip115hot,wp123zy,yunpan139,yunpan189,
yunpanuc,yydf_hzl,leoziyuan,pikpakpan,Q_dongman,
yoyokuakeduanju,TG654TG,WFYSFX02,QukanMovie,
yeqingjie_GJG666,movielover8888_film3,Baidu_netdisk,
D_wusun,FLMdongtianfudi,KaiPanshare,QQZYDAPP,rjyxfx
```

**自定义频道：**
```bash
# 只订阅部分频道
-e CHANNELS=tgsearchers3,Aliyun_4K_Movies,Quark_Movies

# 禁用Telegram频道（只使用插件）
-e CHANNELS=
```

### 代理配置

| 变量名 | 默认值 | 说明 | 示例 |
|--------|--------|------|------|
| `PROXY` | 无 | 代理服务器地址 | `socks5://xxx.xxx.xxx.xxx:7897` |

**支持的代理类型：**
- SOCKS5代理: `socks5://xxx.xxx.xxx.xxx:7897`

**使用场景：**
- 访问被墙的Telegram频道
- 加速国外资源访问
- 企业内网代理

```bash
# 示例
-e PROXY=socks5://xxx.xxx.xxx.xxx:7897
```

### 健康检查配置

| 变量名 | 默认值 | 说明 | 范围 |
|--------|--------|------|------|
| `HEALTH_CHECK_INTERVAL` | `30` | 检查间隔（秒） | `10`-`60` |
| `HEALTH_CHECK_TIMEOUT` | `10` | 检查超时（秒） | `5`-`30` |
| `HEALTH_CHECK_RETRIES` | `3` | 失败重试次数 | `1`-`5` |

**说明：**
- 更小的 `INTERVAL` = 更快发现问题，但更耗资源
- 更大的 `RETRIES` = 更宽容，但恢复更慢

```bash
# 快速响应配置（检测快，恢复快）
-e HEALTH_CHECK_INTERVAL=15 \
-e HEALTH_CHECK_TIMEOUT=5 \
-e HEALTH_CHECK_RETRIES=2

# 保守配置（避免误报）
-e HEALTH_CHECK_INTERVAL=60 \
-e HEALTH_CHECK_TIMEOUT=30 \
-e HEALTH_CHECK_RETRIES=5
```

### 认证配置（可选）

| 变量名 | 默认值 | 说明 | 示例 |
|--------|--------|------|------|
| `AUTH_ENABLED` | `false` | 是否启用认证 | `true` |
| `AUTH_USERS` | 无 | 用户列表 | `admin:pass123,user:pass456` |
| `AUTH_TOKEN_EXPIRY` | `24` | Token有效期（小时） | `24` |
| `AUTH_JWT_SECRET` | 无 | JWT密钥 | `your-secret-key` |

**启用认证：**
```bash
-e AUTH_ENABLED=true \
-e AUTH_USERS=admin:admin123,user:pass456 \
-e AUTH_TOKEN_EXPIRY=24 \
-e AUTH_JWT_SECRET=your-random-secret-key-here
```

---

## 🎯 常见配置场景

### 场景1：个人使用（最小配置）

```bash
docker run -d \
  --name pansou \
  -p 80:80 \
  -v pansou-data:/app/data \
  --restart unless-stopped \
  ghcr.io/fish2018/spansou-web:latest
```

**特点：**
- ✅ 使用所有默认插件和频道
- ✅ 自动健康检查和重启
- ✅ 数据持久化

### 场景2：公网服务（带域名和SSL）

```bash
# 1. 准备SSL证书
mkdir -p /opt/pansou/ssl
# 将证书放到 /opt/pansou/ssl/fullchain.pem 和 privkey.pem

# 2. 启动容器
docker run -d \
  --name pansou \
  -p 80:80 \
  -p 443:443 \
  -e DOMAIN=pansou.example.com \
  -v pansou-data:/app/data \
  -v /opt/pansou/ssl:/app/data/ssl:ro \
  --restart unless-stopped \
  ghcr.io/fish2018/spansou-web:latest
```

### 场景3：需要代理访问Telegram

```bash
docker run -d \
  --name pansou \
  -p 80:80 \
  -e PROXY=socks5://127.0.0.1:7897 \
  -v pansou-data:/app/data \
  --restart unless-stopped \
  --network host \
  ghcr.io/fish2018/spansou-web:latest
```

**注意：**
- 使用 `--network host` 以访问宿主机代理
- 或者将代理服务也容器化并使用 docker 网络

### 场景4：启用访问认证

```bash
docker run -d \
  --name pansou \
  -p 80:80 \
  -e AUTH_ENABLED=true \
  -e AUTH_USERS=admin:MySecretPass123,viewer:ViewOnly456 \
  -e AUTH_TOKEN_EXPIRY=168 \
  -e AUTH_JWT_SECRET=$(openssl rand -base64 32) \
  -v pansou-data:/app/data \
  --restart unless-stopped \
  ghcr.io/fish2018/spansou-web:latest
```

---

## 📁 数据目录说明

### 卷挂载

**推荐：使用命名卷（Docker管理）**
```bash
-v pansou-data:/app/data
```

**或：使用绑定挂载（指定宿主机路径）**
```bash
-v /opt/pansou/data:/app/data
```

### 目录结构详解

```
/app/data/
│
├── cache/                          # 缓存目录（约100MB-1GB）
│   ├── disk/                       # 磁盘缓存
│   │   ├── [hash].cache           # 搜索结果缓存
│   │   └── metadata.db            # 缓存元数据
│   └── qqpd_users/                # QQPD插件数据
│       └── [hash].json            # 用户配置和频道
│
├── logs/                           # 日志目录（建议定期清理）
│   ├── backend/                    # 后端日志
│   │   └── pansou.log             # 主日志文件
│   └── nginx/                      # Nginx日志
│       ├── access.log             # 访问日志
│       └── error.log              # 错误日志
│
└── ssl/                            # SSL证书目录
    ├── fullchain.pem              # 完整证书链
    └── privkey.pem                # 私钥
```