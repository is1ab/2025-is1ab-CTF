FROM python:3.12-slim-bookworm

# 更新 apt 包列表並安裝所有必需的系統依賴
# *** 修改點 1: 添加 redis-server 和 cron ***
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server cron \ 
    nginx vim gcc build-essential \
    libx11-6 libglib2.0-0 libxrender1 libxext6 \
    libfontconfig1 libfreetype6 \
    libjpeg62-turbo \
    libicu72 libstdc++6 \
    curl bzip2 ca-certificates openssl \
    fonts-dejavu-core fonts-freefont-ttf fonts-liberation \
    fonts-noto-cjk \
    xvfb \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# 確保 Fontconfig 緩存目錄存在且可寫
RUN mkdir -p /var/cache/fontconfig \
    && chmod 777 /var/cache/fontconfig \
    && mkdir -p /tmp && chmod 777 /tmp

# *** 修改點 2: 創建 uWSGI 日誌目錄並設置權限 ***
RUN mkdir -p /var/log/uwsgi \
    && chown www-data:www-data /var/log/uwsgi \
    && chmod 755 /var/log/uwsgi

# 複製你的應用程式碼
COPY app/ /app/

# 在安裝其他 Python 依賴之前，先安裝 uWSGI
RUN pip install uwsgi --break-system-packages

# 安裝 Python 依賴
RUN pip install -r /app/requirements.txt --break-system-packages

# 配置 Nginx
RUN cp /app/web/nginx-site.conf /etc/nginx/sites-available/default

# 處理 readflag 相關文件
COPY readflag.c /readflag.c
RUN echo 'flag{fake_flag}' > /flag
RUN chmod 0400 /flag && chown root:root /flag
RUN chmod 0444 /readflag.c && gcc /readflag.c -o /readflag
RUN chown root:root /readflag && chmod 4555 /readflag

# 安裝 PhantomJS
ENV PHANTOMJS_VERSION=2.1.1
RUN cd /tmp &&\
  curl -k -Ls https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 | tar -jx &&\
  cp phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs &&\
  chmod +x /usr/local/bin/phantomjs &&\
  rm -rf /tmp/phantomjs*

# 安裝 pycurl 及其依賴
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev python3-dev \
    && pip install --break-system-packages --no-cache-dir pycurl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# 配置權限
RUN chown -R www-data:www-data /app/web/pdfs
RUN chmod 755 /app/web/pdfs

# 設置 OpenSSL 環境變數
ENV OPENSSL_CONF=/dev/null
ENV SSL_CERT_DIR=/dev/null

EXPOSE 80

# 運行服務
RUN chmod 700 /app/ctrl/start-services.sh
CMD /app/ctrl/start-services.sh
