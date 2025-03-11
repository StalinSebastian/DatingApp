# Stage 1: Build the Angular application
FROM node:22.14-alpine AS build

# Set the working directory in the container
WORKDIR /app

# Copy package files and install dependencies
COPY FrontEnd/package*.json ./
RUN npm install

# Copy the entire Angular project and build for production
COPY FrontEnd/ .
RUN npm run build --prod

# Expose the port on which the app runs
#EXPOSE 4200

# Start the application
#CMD ["npm", "start"]

# Runtime stage
FROM nginx:alpine AS final
COPY --from=build /app/dist/dating-app/browser /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./docker/certs/localhost.pem /etc/nginx/certs/localhost.pem
COPY ./docker/certs/localhost-key.pem /etc/nginx/certs/localhost-key.pem
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]

#ENTRYPOINT ["tail", "-f", "/dev/null"]