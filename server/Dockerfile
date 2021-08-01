FROM node:latest

# Set working directory
WORKDIR /app

# Copy source to working directory
COPY . /app/

# Install dependencies
RUN npm i

# Expose port
EXPOSE 8888

CMD [ "npm", "run", "start" ]
