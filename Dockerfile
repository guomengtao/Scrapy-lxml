# 使用 Python 镜像（因为 Scrapy 是 Python 写的）
FROM python:3.12-slim

# 安装必要的系统库（lxml 编译等需要）
RUN apt-get update && apt-get install -y \
    gcc \
    libxml2-dev \
    libxslt-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 克隆 GitHub 项目
RUN git clone https://github.com/guomengtao/Scrapy-lxml.git .

# 复制 requirements.txt 并安装依赖（利用 Docker 缓存）
RUN pip install --no-cache-dir -r requirements.txt

# 赋予执行权限
RUN chmod +x watch_hf.sh

# 暴露端口（Hugging Face Spaces 需要）
EXPOSE 7860

# 启动应用
CMD ["./watch_hf.sh"]