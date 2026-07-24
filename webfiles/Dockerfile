# Use a lightweight nginx image to serve static files
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy the contents of the webfiles directory into nginx's html folder
COPY . /usr/share/nginx/html/

# Expose port 80 for HTTP traffic
EXPOSE 80

# Nginx starts automatically via the base image's default CMD
CMD ["nginx", "-g", "daemon off;"]
