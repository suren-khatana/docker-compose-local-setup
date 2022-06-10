#!/bin/bash
set -eo pipefail

display_help() {
    echo -e "Usage: $(basename "$0") [-h | --help] [-i | --install] [--start] [--stop]  [-d | --delete] [-b | --backup] \n" >&2
    echo "** DESCRIPTION **"
    echo -e "This script can be used to manage a docker compose based curity identity server installation including an external postgres datasource. \n"
    echo -e "OPTIONS \n"
    echo " --help      show this help message and exit                                                  "
    echo " --install   installs the curity identity server environment                                  "
    echo " --start     starts the curity identity server environment                                    "
    echo " --stop      stops the curity identity server environment                                     "
    echo " --scan      scans the curity identity server docker image for security vulnerabilities       "
    echo " --delete    deletes the docker compose environment                                           "
    echo " --backup    backup idsvr configuration                                                       "  
}


greeting_message() {
  echo "|------------------------------------------------------------------|"
  echo "|  Docker compose based Curity Identity Server Installation        |"
  echo "|------------------------------------------------------------------|"
  echo "| Following components are going to be installed :                 |"
  echo "|------------------------------------------------------------------|"
  echo "| [1] NGINX REVERSE PROXY                                          |"
  echo "| [2] CURITY IDENTITY SERVER ADMIN NODE                            |"
  echo "| [3] CURITY IDENTITY SERVER RUNTIME NODE                          |"
  echo "| [4] POSTGRES DATABASE                                            |"
  echo "|------------------------------------------------------------------|" 
  echo -e "\n"
}

find_host() {
  echo "Determining OS Type.. "
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)     ostype=Linux;;
    Darwin*)    ostype=Mac;;
    *)          ostype="UNKNOWN:${unameOut}"
  esac;
  export OS_TYPE=${ostype}
  echo "Host is detected as ${OS_TYPE}"
}

pre_requisites_check() {
# Check if docker & docker-compose are installed
if ! [[ $(docker --version) && $(docker-compose --version) ]]; then
    echo "Please install docker and docker-compose to continue with the deployment .."
    exit 1 
fi

# Check for license file
if [ ! -f './idsvr-config/license.json' ]; then
  echo "Please copy a license.json file in the idsvr-config directory to continue with the deployment. License could be downloaded from https://developer.curity.io/"
  exit 1
fi

# Determine the host OS type
find_host

# Check if trivy is installed
if ! [[ $(trivy --version) ]]; then
    if [[ $OS_TYPE == Mac ]]; then
        echo "Trivy is not installed, setting it up .."
        brew install aquasecurity/trivy/trivy     
    fi
    
fi

}


scan_idsvr_docker_image(){
  echo "|--------------------------------------------------------------------------------------------------------|"
  echo " Scanning Identity server docker image for HIGH & CRITICAL securtiy vulnerabilities ....                 "
  echo -e "\n"
  trivy image --severity HIGH,CRITICAL curity-idsvr:local
  echo "|--------------------------------------------------------------------------------------------------------|"
  echo -e "\n\n"

}


is_pki_already_available() {
  echo -e "Verifying whether the certificates are already available .."
  if [[ -f ./certs/curity.local.ssl.key && -f ./certs/curity.local.ssl.pem ]] ; then
    echo -e "curity.local.ssl.key & curity.local.ssl.pem certificates already exist.., skipping regeneration of certificates\n"
    true
  else
    echo -e "curity.local.ssl.key & curity.local.ssl.pem certificates are not available, going to be generated..\n"
    false
  fi
  
}


generate_self_signed_certificates() {
  if ! is_pki_already_available ; then
    echo -e "Generating necessary self-signed certificates for secure communication ..\n"
    source ./create-self-signed-certs.sh
  fi

}


build_environment() {
  echo -e "Building docker images and bringing up the environment ...\n"
  # Build & start the environment 
  docker-compose up --build -d
  echo -e "\n"
  
}

environment_info() {
  echo "Environment Installation Status :"
  echo -e "\n"
  docker-compose ps
  echo -e "\n\n"

  echo "|--------------------------------------------------------------------------------------------------------------|"
  echo "|                                Environment URLS & Endpoints                                                  |"
  echo "|--------------------------------------------------------------------------------------------------------------|"
  echo "|                                                                                                              |"
  echo "| [ADMIN UI]          https://admin.curity.local/admin                                                         |"
  echo "| [OIDC METADATA]     https://login-internal.curity.local/internal/~/.well-known/openid-configuration          |"
  echo "| [OIDC METADATA]     https://login-external.curity.local/extrnal/~/.well-known/openid-configuration           |"
  echo "| [DEVOPS DASHBOARD]  https://admin.curity.local/admin/dashboard                                               |"
  echo "|                                                                                                              |"
  echo "| * Curity administrator username is 'admin' and password can be found in the docker-compose.yaml file         |"
  echo "| * Remember to add certs/curity.local.ca.pem to operating systems certificate trust store  &                  |"
  echo "|   127.0.0.1  admin.curity.local login-internal.curity.local login-external.curity.local entry to /etc/hosts |"
  echo "|--------------------------------------------------------------------------------------------------------------|" 
  echo -e "\n"
}

start_environment() {
  echo -e "Starting the environment ...\n"
  docker-compose start
  docker-compose ps
}

stop_environment() {
  echo -e "Stopping the environment ...\n"
  docker-compose stop
}

idsvr_backup() {
  # Create backups directory to hold backup xml files
  mkdir -p backups

  if [[ "$(docker ps -q -f status=running -f name=curity-admin)" ]]
  then
    backup_file_name="server-config-backup-$(date +"%Y-%m-%d-%H-%M-%S").xml"
    echo "Backing up server configuration in to a file named => $backup_file_name"

    docker exec curity-admin idsvr -d > ./backups/"$backup_file_name"
    echo "Backup completed and stored in a file => ./backups/$backup_file_name " 
  else
    echo "Backup couldn't be taken since the 'curity-admin' container is not running.."
  fi
  
}

tear_down_environment() {
  read -p "containers & images would be deleted, Are you sure? [Y/y N/n] :" -n 1 -r
  echo -e "\n"

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    # Take backup before deletion if the containers are running
    idsvr_backup || true
    echo -e "\n"
    docker-compose down --rmi all || true
  else
    echo "Aborting the operation .."
    exit 1
  fi
}


# ==========
# entrypoint
# ==========

case $1 in
  -i | --install)
    greeting_message
    pre_requisites_check
    generate_self_signed_certificates
    build_environment
    if [[ $OS_TYPE == Mac ]]; then
     # scan_idsvr_docker_image    
      echo ""
    fi  
    environment_info
    ;;
  --start)
    start_environment
    ;;
  --stop)
    stop_environment
    ;;
  --scan)
    scan_idsvr_docker_image
    ;;
  -d | --delete)
    tear_down_environment
    ;;
  -b | --backup)
    idsvr_backup
    ;;
  -h | --help)
    display_help
    ;;
  *)
    echo "[ERROR] Unsupported options"
    display_help
    exit 1
    ;;
esac



