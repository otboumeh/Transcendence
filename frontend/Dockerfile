FROM node:18-alpine

WORKDIR /app

# Copiar definiciones de paquetes
COPY package.json ./
COPY tsconfig.json ./

# Instalar dependencias
RUN npm install

# Copiar el código fuente
COPY src ./src

EXPOSE 3000

CMD ["npm", "start"]
