#!/bin/bash

# Check if docker & docker-compose are installed
if ! [[ $(docker --version) && $(docker-compose --version) ]]; then
    echo "Please install docker and docker-compose to continue with the deployment .."
fi

# Check for license availability
if [ ! -f './idsvr-config/license.json' ]; then
  echo "Please copy a license.json file in the idsvr-config directory to continue with the deployment. License could be downloaded from https://developer.curity.io/"
  exit 1
fi


# Build & Start the environment 
docker-compose up --build -d

echo -e "\n"
echo "*****************************************************************************************************"
echo "Admin UI is available at https://localhost:6749/admin                                                "
echo "DevOps dashboard UI is available at https://localhost:6749/admin/dashboard                           "
echo "OpenID connect metadata is available at https://localhost:8443/~/.well-known/openid-configuration    "

echo "Curity administrator username is admin and password can be found in the docker-compose.yaml file     "
echo "*****************************************************************************************************"
