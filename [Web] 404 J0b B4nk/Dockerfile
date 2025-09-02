FROM node:18-alpine AS builder

# 安裝必要工具（避免某些依賴編譯失敗）
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 複製依賴檔案並安裝
COPY app/package*.json ./
RUN npm install

# 複製程式碼並 build
COPY app/ ./
RUN npm run build


# --------- Runtime stage ---------
FROM node:18-alpine

WORKDIR /app

# 複製 build 結果與依賴
COPY --from=builder /app /app

# 複製 flag
COPY flag.txt /flag.txt

# 設定環境變數
ENV NODE_ENV=production
ENV PORT=1337

EXPOSE 1337

# 設定權限給 node user
RUN chown -R node:node /app

USER node

CMD ["npm", "start"]
