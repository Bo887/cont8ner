#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script"
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Invalid number of args"
    exit 2
fi

CONTAINER_NAME=$1
umount $CONTAINER_NAME/image/*/proc
umount $CONTAINER_NAME/root

rm -rf $CONTAINER_NAME
