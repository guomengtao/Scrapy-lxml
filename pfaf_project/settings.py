import os
import logging
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# --- Scrapy 项目基本配置 ---
BOT_NAME = 'pfaf_project'
SPIDER_MODULES = ['pfaf_project.spiders']
NEWSPIDER_MODULE = 'pfaf_project.spiders'

# --- 日志精简配置 ---

# 1. 设置 Scrapy 自身的日志级别为 INFO
# 这样就不会打印抓取到的 Item 详情（HTML），只打印启动/结束统计和错误
LOG_LEVEL = 'INFO'

# 2. 屏蔽第三方库的烦人 DEBUG 信息
# 解决你刚才看到的 httpcore/httpx/supabase 刷屏问题
logging.getLogger('httpcore').setLevel(logging.WARNING)
logging.getLogger('httpx').setLevel(logging.WARNING)
logging.getLogger('supabase').setLevel(logging.WARNING)

# Supabase 配置
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://your-project-id.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY', 'your-anon-key')

# 建议稍微加速：既然你已经有几万条数据，只要不被封，可以适度提高并发
CONCURRENT_REQUESTS = 10       # 从 5 提到 10
DOWNLOAD_DELAY = 1.0           # 从 1.5 降到 1.0

# --- 必须添加这段配置，否则数据不会存入 Supabase ---
ITEM_PIPELINES = {
    'pfaf_project.pipelines.SupabaseBatchPipeline': 300,
}

# 启用断点续爬，进度会保存在根目录下的 crawls 文件夹中
JOBDIR = 'crawls/pfaf_repair_v1'