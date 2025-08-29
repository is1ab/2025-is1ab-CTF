FROM node:18-alpine

# Install dependencies
WORKDIR /app

COPY app/package*.json ./
RUN npm install

# Copy app source code
COPY app/ .
RUN npm run build

COPY flag.txt /flag.txt

# Run the app
ENV NODE_ENV production
ENV PORT 1337

EXPOSE 1337

USER node
CMD ["npm", "start"]
