#!/bin/bash

# ========================================================
# 这个脚本用于在 Hugging Face Spaces 上保持应用活跃
# 自动定位 Scrapy 项目并循环执行爬虫
# ========================================================

echo "🚀 启动 Hugging Face Spaces 应用..."
echo "📊 初始内存: $(free -h | grep Mem | awk '{print $3"/"$2}')"

# 设置信号处理，优雅退出
trap 'echo "🛑 收到退出信号，正在停止..."; kill $HTTP_PID 2>/dev/null; exit 0' SIGTERM SIGINT

# 1. 启动 HTTP 服务器保持端口活跃 (Hugging Face 必要要求)
python3 -m http.server 7860 &
HTTP_PID=$!

# 等待服务器启动
sleep 3
echo "📡 HTTP 服务器已启动 (PID: $HTTP_PID)"

# 2. 自动寻找 Scrapy 项目根目录 (寻找 scrapy.cfg)
echo "🔍 正在定位 Scrapy 项目..."
CONFIG_PATH=$(find /app -name "scrapy.cfg" | head -n 1)

if [ -z "$CONFIG_PATH" ]; then
    echo "❌ 错误: 在 /app 及其子目录中未找到 scrapy.cfg"
    echo "📂 当前 /app 目录结构如下:"
    ls -R /app
    exit 1
fi

PROJECT_ROOT=$(dirname "$CONFIG_PATH")
echo "✅ 找到项目根目录: $PROJECT_ROOT"

# 3. 循环执行爬虫任务
COUNTER=0
while true; do
    COUNTER=$((COUNTER + 1))
    echo ""
    echo "===================================================="
    echo "🔄 第 $COUNTER 轮爬虫执行开始"
    echo "⏰ 时间: $(date)"
    
    # 切换到项目根目录（scrapy crawl 必须在此运行）
    cd "$PROJECT_ROOT"
    
    # 检查可用爬虫列表 (可选调试)
    # scrapy list
    
    # 启动爬虫，使用你定义的爬虫名: pfaf_repair
    # --loglevel=INFO 减少日志冗余
    scrapy crawl pfaf_repair --loglevel=INFO
    
    if [ $? -eq 0 ]; then
        echo "✅ 轮次 $COUNTER 执行成功完成"
    else
        echo "⚠️ 轮次 $COUNTER 爬虫执行异常或无数据"
    fi
    
    echo "⏰ 完成时间: $(date)"
    echo "📊 当前内存: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo "⏳ 等待 300 秒后进行下一轮..."
    echo "===================================================="
    
    sleep 300
    
    # 每 10 轮清理一次系统缓存（Hugging Face 容器权限内尽量执行）
    if [ $((COUNTER % 10)) -eq 0 ]; then
        echo "🧹 正在尝试清理缓存..."
        sync 2>/dev/null
    fi
done

# 如果循环意外结束，停止 HTTP 服务器
kill $HTTP_PID 2>/dev/null || true