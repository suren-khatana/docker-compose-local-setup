# Get the base image
FROM curity.azurecr.io/curity/idsvr:latest

# Copy the license to load at startup
COPY license.json /opt/idsvr/etc/init/license/

# Copy idsvr custom config 
COPY server-config.xml /opt/idsvr/etc/init/

# Extra tools - for development troubleshooting only
USER root
RUN apt-get update
RUN apt-get install curl -y
USER idsvr
