FROM nginx:latest

# Copy custom nginx configuration 
COPY ./reverse-proxy/nginx.conf /etc/nginx/nginx.conf

# Copy self signed SSL certificates 
COPY ./certs/curity.local.ssl.pem /etc/ssl/certs/ssl.pem
COPY ./certs/curity.local.ssl.key /etc/ssl/private/ssl.key