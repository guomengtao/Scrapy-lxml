import scrapy 

class PfafRepairItem(scrapy.Item): 
    id = scrapy.Field() 
    raw_html = scrapy.Field() 
    status = scrapy.Field() 
    error_log = scrapy.Field() 
    current_retry = scrapy.Field()