#!/usr/bin/env python3
import sys
import os

# 添加当前目录到Python路径
sys.path.insert(0, os.path.dirname(__file__))

from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

def main():
    # 手动设置项目配置
    settings = get_project_settings()
    
    # 手动设置项目特定的配置
    settings.set('BOT_NAME', 'pfaf_project')
    settings.set('SPIDER_MODULES', ['pfaf_project.spiders'])
    settings.set('NEWSPIDER_MODULE', 'pfaf_project.spiders')
    
    # 加载我们的设置文件
    from pfaf_project import settings as project_settings
    settings.setmodule(project_settings, priority='project')
    
    # 创建爬虫进程
    process = CrawlerProcess(settings)
    
    # 运行爬虫
    process.crawl('pfaf_repair')
    process.start()

if __name__ == '__main__':
    main()