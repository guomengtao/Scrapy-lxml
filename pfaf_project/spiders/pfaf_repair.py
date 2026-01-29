import scrapy
from supabase import create_client

class PfafRepairSpider(scrapy.Spider):
    name = "pfaf_repair"
    allowed_domains = ["pfaf.org"]

    def start_requests(self):
        # 显式使用 settings.get 获取配置
        url = self.settings.get("SUPABASE_URL")
        key = self.settings.get("SUPABASE_KEY")
        
        # 检查配置是否有效（不是默认值）
        if not url or url == "https://your-project-id.supabase.co" or not key or key == "your-anon-key":
            self.logger.error("❌ Supabase 配置未正确加载，请检查 settings.py 或 .env 文件")
            self.logger.error(f"URL: {url}")
            self.logger.error(f"KEY: {key[:20] if key else 'None'}...")
            return

        supabase = create_client(url, key)

        # 1. 彻底移除反斜杠，使用括号包裹查询语句（最安全）
        res = (
            supabase.table("raw_plants")
            .select("id, source_url, retry_count")
            .eq("status", "pending")
            .lt("retry_count", 5)
            .limit(100)
            .execute()
        )

        self.logger.info(f"🚀 领取的待修任务数量: {len(res.data)}")

        for rec in res.data:
            yield scrapy.Request(
                url=rec['source_url'],
                callback=self.parse,
                meta={'p_id': rec['id'], 'retry_count': rec['retry_count']},
                dont_filter=True
            )

    def parse(self, response):
        # 2. 使用相对导入，防止因项目目录名变动导致的导入失败
        try:
            from pfaf_project.items import PfafRepairItem
        except ImportError:
            from ..items import PfafRepairItem

        item = PfafRepairItem()
        item['id'] = response.meta['p_id']
        item['current_retry'] = response.meta['retry_count']
        
        html = response.text
        if response.status == 200 and len(html) > 5000:
            item['raw_html'] = html
            item['status'] = 'success'
            item['error_log'] = 'Success'
            self.logger.info(f"✅ ID {item['id']} 修复成功")
        else:
            item['raw_html'] = 'FAILED'
            item['status'] = 'pending'
            item['error_log'] = f"Fail: {response.status}"
            self.logger.warning(f"❌ ID {item['id']} 抓取异常")
        
        yield item