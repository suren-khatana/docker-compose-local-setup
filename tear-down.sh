#!/bin/bash
set -e

read -p "Containers would be deleted, Are you sure? [Y/y N/n] :" -n 1 -r
echo  #  Move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  # Stop the containers gracefully and then tear down
  docker-compose stop
  docker-compose rm --force
else
  echo "Aborting the operation .."
  exit 1
fi

