import time
import redis
from selenium import webdriver
import os

db = redis.Redis()

PDF_PATH = '/app/web/pdfs/'

class Document:
    @classmethod
    def __init__(self, url, sid):
        self.url = url
        self.fileid = str(round(time.time() * 1000))
        self.html2pdf(url)
        self.save(sid)
    @classmethod
    def html2pdf(self, url):
        driver = webdriver.PhantomJS(service_log_path='/dev/null')
        try:
            driver.get(url)
            page_source = driver.page_source

            temp_html_path = os.path.join(PDF_PATH, self.fileid + '.pdf')
            with open(temp_html_path, 'w', encoding='utf-8') as f:
                f.write(page_source)

        except Exception as e:
            print(f"Error processing {url}: {e}")

    @classmethod
    def save(self, sid):
        if sid != '':
            db.hset(sid, self.url, self.fileid)
            db.expire(sid, 15 * 60) #refresh session

    @staticmethod
    def list(sid):
        if sid != '':
            docs = db.hgetall(sid)
            docs = { key.decode(): '/api/download?id=' + val.decode() for key, val in docs.items() }
            return docs



