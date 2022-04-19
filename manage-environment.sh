#!/bin/bash
set -eo pipefail

display_help() {
    echo -e "Usage: $(basename "$0") [-h | --help] [-i | --install] [--start] [--stop]  [-d | --delete] [-b | --backup] \n" >&2
    echo "** DESCRIPTION **"
    echo -e "This script can be used to manage a docker compose based curity identity server installation including an external postgress datasource. \n"
    echo -e "OPTIONS \n"
    echo " --help      show this help message and exit                   "
    echo " --install   installs the curity identity server environment   "
    echo " --start     starts the curity identity server environment     "
    echo " --stop      stops the curity identity server environment      "
    echo " --delete    deletes the docker compose environment            "
    echo " --backup    backup idsvr configuration                        "  
}



pre_requisites_check() {
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
}

is_pki_already_available() {
  echo -e "Verifying whether the certificates are already available ..\n"
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
    echo -e "Generating neccessary self-signed certificates for secure communication ..\n"
    source ./create-self-signed-certs.sh
  fi

}


build_environment() {
  echo -e "Building docker images and bringing up the environment ...\n"
  # Build & start the environment 
  docker-compose up --build -d
  docker-compose ps

  echo -e "\n"
  echo "****************************************** Connection Info *******************************************"
  echo "Admin UI is available at https://admin.curity.local/admin                                             "
  echo "DevOps dashboard UI is available at https://admin.curity.local/admin/dashboard                        "
  echo "OpenID connect metadata is available at https://login.curity.local/~/.well-known/openid-configuration "

  echo "Curity administrator username is 'admin' and password can be found in the docker-compose.yaml file    "
  echo "******************************************************************************************************"

}

start_environment() {
  echo -e "Starting the environment ...\n"
  docker-compose start
  docker-compose ps
}

stop_environment() {
  echo -e "Stoping the environment ...\n"
  docker-compose stop
}

idsvr_backup() {
  echo "Backing up server configuration in to a file named server-config-backup-YYYY-MM-DD-hh-mm-ss.xml"
  backup_file_name="server-config-backup-$(date +"%Y-%m-%d-%H-%M-%S").xml"
  docker exec curity-idsvr-admin idsvr -d > "$backup_file_name"

  echo "Backup completed and stored in a file : $backup_file_name " 
}

tear_down_environment() {
  read -p "Containers would be deleted, Are you sure? [Y/y N/n] :" -n 1 -r
  echo  #  Move to a new line

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
     # Take backup before deletion
    idsvr_backup
    echo -e "\n"
    # Stop the containers gracefully and then tear down
    docker-compose stop
    docker-compose rm --force
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
    pre_requisites_check
    generate_self_signed_certificates
    build_environment
    ;;
  --start)
    start_environment
    ;;
  --stop)
    stop_environment
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



