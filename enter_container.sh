#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Invalid number of args."
    echo "Usage: ./enter_container.sh [container_name]"
    exit 2
fi

CONTAINER_NAME=$1

cd $CONTAINER_NAME

#TODO: Need to use nsenter
ip netns exec ${CONTAINER_NAME} unshare -f chroot image/ /bin/bash
