# syntax=docker/dockerfile:1
FROM node:20-alpine
WORKDIR /app
ENV CI=true
COPY package*.json ./
# cache de npm para acelerar
RUN --mount=type=cache,target=/root/.npm npm ci || npm install
COPY . .
EXPOSE 3000
# En dev: servidor con hot-reload; en prod cambia a serve/NGINX
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
