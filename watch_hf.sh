#!/bin/bash

# 这个脚本用于在 Hugging Face Spaces 上保持应用活跃
# 同时循环启动 Scrapy 爬虫

echo "🚀 启动 Hugging Face Spaces 应用..."

# 启动一个简单的 HTTP 服务器来保持端口活跃
python3 -m http.server 7860 &
HTTP_PID=$!

# 等待服务器启动
sleep 3

echo "📡 HTTP 服务器已启动 (PID: $HTTP_PID)"

# 循环执行爬虫任务
while true; do
    echo "🔄 开始新一轮爬虫执行..."
    echo "⏰ 当前时间: $(date)"
    
    # 启动 Scrapy 爬虫
    cd /app
    scrapy crawl pfaf_repair --loglevel=INFO
    
    # 记录爬虫执行完成
    echo "✅ 爬虫执行完成，等待下一次执行..."
    echo "⏰ 完成时间: $(date)"
    
    # 等待一段时间后再次执行（例如5分钟）
    echo "⏳ 等待300秒后再次执行..."
    sleep 300
    
    echo ""
echo "========================================"
echo ""
done

# 如果循环意外结束，也停止 HTTP 服务器
kill $HTTP_PID