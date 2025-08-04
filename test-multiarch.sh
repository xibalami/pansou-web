#!/bin/bash

# 多架构支持测试脚本
echo "🚀 PanSou Web 多架构支持测试"
echo "================================"

# 检查当前系统架构
echo "📋 当前系统信息："
echo "架构: $(uname -m)"
echo "系统: $(uname -s)"

# 拉取并测试镜像
echo ""
echo "🐳 拉取多架构镜像..."
docker pull ghcr.io/fish2018/pansou-web:latest

# 检查镜像信息
echo ""
echo "🔍 镜像信息："
docker image inspect ghcr.io/fish2018/pansou-web:latest | grep Architecture || echo "架构信息获取失败"

# 快速测试运行
echo ""
echo "✅ 快速测试运行..."
docker run --rm --name pansou-test -d -p 8080:80 ghcr.io/fish2018/pansou-web:latest

# 等待服务启动
echo "⏳ 等待服务启动 (10秒)..."
sleep 10

# 健康检查
echo ""
echo "🏥 健康检查："
if curl -s http://localhost:8080/api/health > /dev/null; then
    echo "✅ 服务运行正常"
    curl -s http://localhost:8080/api/health | jq . || curl -s http://localhost:8080/api/health
else
    echo "❌ 服务运行异常"
    docker logs pansou-test
fi

# 清理
echo ""
echo "🧹 清理测试容器..."
docker stop pansou-test 2>/dev/null || true

echo ""
echo "🎉 测试完成！"