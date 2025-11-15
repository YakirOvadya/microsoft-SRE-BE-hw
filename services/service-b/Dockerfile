FROM node:18-slim

RUN apt-get update && apt-get install -y curl && apt-get clean

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 3002

CMD ["node", "app.js"]