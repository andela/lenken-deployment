# Create image based on the official Node 7 image from dockerhub
FROM node:7.7.2-alpine

# Create a directory where our app will be placed
RUN mkdir -p /usr/src/app

# Change directory so that our commands run inside this new directory
WORKDIR /usr/src/app

# Get all the code needed to run the app
COPY . /usr/src/app

# Install dependecies
RUN yarn install

# Install angular
RUN npm install -g @angular/cli

# Export production environment
ENV ENV=production

# Build the application
RUN ng build

# Expose the port the app runs in
EXPOSE 4200

# Serve the app
CMD ["yarn", "start:prod"]
