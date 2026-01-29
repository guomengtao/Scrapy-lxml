#!/bin/bash

# ========================================================
# 自动定位 Scrapy 项目并执行爬虫
# ========================================================

echo "🚀 启动 Hugging Face Spaces 应用..."

# 优雅退出处理
trap 'echo "🛑 停止中..."; kill $HTTP_PID 2>/dev/null; exit 0' SIGTERM SIGINT

# 1. 启动 HTTP 服务器 (Hugging Face 必要)
python3 -m http.server 7860 &
HTTP_PID=$!
sleep 2

# 2. 【核心修复】自动寻找 scrapy.cfg 所在的目录
echo "🔍 正在全盘搜索 scrapy.cfg..."
CONFIG_FILE=$(find /app -name "scrapy.cfg" | head -n 1)

if [ -z "$CONFIG_FILE" ]; then
    echo "❌ 严重错误: 整个 /app 目录下都找不到 scrapy.cfg 文件！"
    echo "📂 当前目录树结构如下 (请检查文件是否成功克隆):"
    ls -R /app
    exit 1
fi

# 获取项目根目录
PROJECT_ROOT=$(dirname "$CONFIG_FILE")
echo "✅ 成功找到项目根目录: $PROJECT_ROOT"

# 3. 循环执行任务
COUNTER=0
while true; do
    COUNTER=$((COUNTER + 1))
    echo ""
    echo "========================================"
    echo "🔄 第 $COUNTER 轮爬虫执行开始"
    echo "⏰ 时间: $(date)"
    
    # 【关键步骤】必须进入包含 scrapy.cfg 的目录
    cd "$PROJECT_ROOT"
    
    # 执行爬虫
    # 注意：请确保 pfaf_repair 是你在 spiders/ 文件夹下定义的 name
    scrapy crawl pfaf_repair --loglevel=INFO
    
    if [ $? -eq 0 ]; then
        echo "✅ 爬虫轮次执行成功"
    else
        echo "⚠️ 爬虫退出，状态码异常 (可能无数据或报错)"
    fi
    
    echo "⏳ 等待 300 秒..."
    sleep 300
done