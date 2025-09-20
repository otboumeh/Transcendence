# Start with a clean Node.js environment
# -alpine
FROM node:lts

# Set the working directory inside the container
WORKDIR /app

# Copy package.json to install dependencies
COPY package.json .

# Install all dependencies (tailwindcss and serve)
RUN npm install

# Copy all your other files
COPY . .

# Tell Docker that the container will listen on port 3000
EXPOSE 3000

# The command to run when the container starts
CMD [ "npm", "start" ]