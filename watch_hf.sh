#!/bin/bash

# ========================================================
# 针对 pfaf_project 目录结构优化的启动脚本
# ========================================================

echo "🚀 启动 Hugging Face Spaces 应用..."

# 设置信号处理
trap 'echo "🛑 停止中..."; kill $HTTP_PID 2>/dev/null; exit 0' SIGTERM SIGINT

# 1. 启动 HTTP 服务器 (监听 7860 端口)
python3 -m http.server 7860 &
HTTP_PID=$!

sleep 3
echo "📡 HTTP 服务器已启动 (PID: $HTTP_PID)"

# 2. 循环执行爬虫
COUNTER=0
while true; do
    COUNTER=$((COUNTER + 1))
    echo ""
    echo "========================================"
    echo "🔄 第 $COUNTER 轮爬虫执行开始..."
    echo "⏰ 当前时间: $(date)"
    
    # 【核心修复点】进入包含 scrapy.cfg 的子目录
    cd /app/pfaf_project
    
    # 打印当前目录确认一下 (调试用)
    echo "📂 当前运行目录: $(pwd)"
    
    # 执行爬虫
    # 注意：请确保 pfaf_repair 是你在 spiders 目录下定义的爬虫名
    if scrapy crawl pfaf_repair --loglevel=INFO; then
        echo "✅ 爬虫执行成功完成"
    else
        echo "⚠️ 爬虫执行遇到错误，请检查项目名或爬虫名"
    fi
    
    echo "⏰ 完成时间: $(date)"
    echo "⏳ 等待 300 秒后再次执行..."
    sleep 300
    
    # 每 10 轮清理一次缓存
    if [ $((COUNTER % 10)) -eq 0 ]; then
        sync
    fi
done

# 停止服务器
kill $HTTP_PID 2>/dev/null || true