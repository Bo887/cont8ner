#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script."
    exit 1
fi

if [[ $# -ne 2 ]]; then
    echo "Invalid number of args."
    echo "Usage: ./init_container.sh [container_name] [user_name]"
    echo "Currently, the image has to be a .tar.gz file."
    exit 2
fi

CONTAINER_NAME=$1
USER_NAME=$2

echo "Setting up user $USER_NAME..."
sudo adduser $USER_NAME

echo "Switching to user $USER_NAME..."
su - $USER_NAME

/bin/bash
