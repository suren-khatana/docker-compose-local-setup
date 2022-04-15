#!/bin/bash
set -e

# Check if docker & docker-compose are installed
if ! [[ $(docker --version) && $(docker-compose --version) ]]; then
    echo "Please install docker and docker-compose to continue with the deployment .."
    exit 1 
fi

# Check for license availability
if [ ! -f './idsvr-config/license.json' ]; then
  echo "Please copy a license.json file in the idsvr-config directory to continue with the deployment. License could be downloaded from https://developer.curity.io/"
  exit 1
fi

echo "Generating neccessary self-signed certificates for secure communication .."

source ./create-self-signed-certs.sh
echo -e "\n"

echo "Building docker images and bringing up the environment ..."
# Build & start the environment 
docker-compose up --build -d

echo -e "\n"
docker-compose ps

echo -e "\n"
echo "****************************************** Connection Info *******************************************"
echo "Admin UI is available at https://admin.curity.local/admin                                             "
echo "DevOps dashboard UI is available at https://admin.curity.local/admin/dashboard                        "
echo "OpenID connect metadata is available at https://login.curity.local/~/.well-known/openid-configuration "

echo "Curity administrator username is 'admin' and password can be found in the docker-compose.yaml file    "
echo "******************************************************************************************************"
