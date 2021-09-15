FROM node:latest

WORKDIR /server

# install dependencies
COPY ./server/package*.json /server/
RUN npm i

# Copy backend
COPY ./server/dist /server

# Copy frontend
COPY ./bettertimetable/build/web /client

# Expose port
EXPOSE 8888

CMD [ "node", "app.js" ]
