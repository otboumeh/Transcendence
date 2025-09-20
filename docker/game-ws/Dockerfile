# syntax=docker/dockerfile:1
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci || npm install
COPY . .
EXPOSE 8080
CMD ["npm", "start"]
