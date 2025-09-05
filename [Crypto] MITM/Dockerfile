FROM python:3.11-slim

# 安裝必要的系統套件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 建立 app 目錄
WORKDIR /app

# 複製程式碼到容器中
COPY server.py .

# 安裝 pycryptodome（你用到了 AES、Padding 等）
RUN pip install pycryptodome

# 建立 flag 檔案（實際 CTF 可以 bind mount 或改掉）
COPY flag.txt .

# 暴露連接埠
EXPOSE 1337

# 啟動伺服器
CMD ["python", "server.py"]