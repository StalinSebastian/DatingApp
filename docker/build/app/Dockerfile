# Stage 1: Build the Angular application
FROM node:22.14-alpine AS build

# Set the working directory in the container
WORKDIR /app

# Copy package files and install dependencies
COPY FrontEnd/package*.json ./
RUN npm install

# Copy the entire Angular project and build for production
COPY FrontEnd/. ./
RUN npm run build

# Expose the port on which the app runs
EXPOSE 4200

# Start the application
CMD ["npm", "start"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]