FROM nginx:alpine

# 运行时依赖
RUN apk add --no-cache ca-certificates tzdata curl

# 时区
ENV TZ=Asia/Shanghai

# 后端与插件默认配置
ENV PANSOU_PORT=8888
ENV PANSOU_HOST=127.0.0.1
ENV ENABLED_PLUGINS=labi,zhizhen,shandian,duoduo,muou,wanou

# Telegram 频道（可按需改）
ENV CHANNELS=tgsearchers3,Aliyun_4K_Movies,bdbdndn11,yunpanx,bsbdbfjfjff,yp123pan,sbsbsnsqq,yunpanxunlei,tianyifc,BaiduCloudDisk,txtyzy,peccxinpd,gotopan,PanjClub,kkxlzy,baicaoZY,MCPH01,bdwpzhpd,ysxb48,jdjdn1111,yggpan,MCPH086,zaihuayun,Q66Share,Oscar_4Kmovies,ucwpzy,shareAliyun,alyp_1,dianyingshare,Quark_Movies,XiangxiuNBB,ydypzyfx,ucquark,xx123pan,yingshifenxiang123,zyfb123,tyypzhpd,tianyirigeng,cloudtianyi,hdhhd21,Lsp115,oneonefivewpfx,qixingzhenren,taoxgzy,Channel_Shares_115,tyysypzypd,vip115hot,wp123zy,yunpan139,yunpan189,yunpanuc,yydf_hzl,leoziyuan,pikpakpan,Q_dongman,yoyokuakeduanju

# 性能默认
ENV CACHE_ENABLED=true
ENV CACHE_TTL=3600
ENV MAX_CONCURRENCY=200
ENV MAX_PAGES=30

WORKDIR /app

# 由 Buildx 注入，选择对应二进制
ARG TARGETARCH

# 后端二进制（由 GitHub Actions 预先构建）
COPY pansou-${TARGETARCH} /app/pansou
RUN chmod +x /app/pansou

# 前端构建产物（由 GitHub Actions 预先构建）
COPY frontend-dist /app/frontend/dist/

# 启动脚本
COPY start.sh /app/
RUN chmod +x /app/start.sh

# 目录与 Nginx 配置
RUN mkdir -p /app/data /app/logs /var/log/nginx /etc/nginx/conf.d

# 健康检查：跟随 Render 注入的 $PORT（本地无则 80）
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f "http://127.0.0.1:${PORT:-80}/api/health" || exit 1

EXPOSE 80 443
VOLUME ["/app/data", "/app/logs"]

CMD ["/app/start.sh"]
