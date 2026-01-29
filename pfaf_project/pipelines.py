from supabase import create_client

class SupabaseBatchPipeline:
    def __init__(self):
        self.buffer = []
        self.batch_size = 20  # 建议维持在 20-50 之间，平衡网络开销与稳定性

    def open_spider(self, spider):
        # 从 settings 获取凭证并初始化
        url = spider.settings.get("SUPABASE_URL")
        key = spider.settings.get("SUPABASE_KEY")
        if not url or not key:
            spider.logger.error("❌ Pipeline 未能加载 Supabase 凭证，请检查 settings.py")
        self.supabase = create_client(url, key)

    def process_item(self, item, spider):
        self.buffer.append(item)
        if len(self.buffer) >= self.batch_size:
            self.flush(spider)
        return item

    def flush(self, spider):
        if not self.buffer:
            return
        
        spider.logger.info(f"💾 正在同步 {len(self.buffer)} 条数据到数据库...")
        
        for i in self.buffer:
            try:
                # 核心改动：使用 update 替代 upsert
                # 这样数据库会保留原有的 latin_name，只修改我们提供的字段
                data = {
                    "raw_html": i['raw_html'],
                    "status": i['status'],
                    "error_log": i['error_log'],
                    "retry_count": i['current_retry'] + 1
                }
                
                self.supabase.table("raw_plants") \
                    .update(data) \
                    .eq("id", i['id']) \
                    .execute()
                
            except Exception as e:
                # 使用 spider.logger 记录，这样即便是在后台运行也能在日志看到错误 ID
                spider.logger.error(f"!!! ID {i['id']} 写入失败: {str(e)}")
        
        # 清空缓冲区
        self.buffer = []

    def close_spider(self, spider):
        # 爬虫关闭前，确保缓冲区里剩余的数据也能被存入
        self.flush(spider)