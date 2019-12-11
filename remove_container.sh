#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Invalid number of args."
    echo "Usage: ./remove_container [container_name]"
    exit 2
fi

CONTAINER_NAME=$1

echo "Unmounting procfs..."
umount $CONTAINER_NAME/root/proc

echo "Unmounting overlayfs..."
umount $CONTAINER_NAME/root

echo "Removing VETH pair..."
VETH="veth1"
ip li delete ${VETH} 2>/dev/null

echo "Removing netns..."
ip netns del $CONTAINER_NAME &>/dev/null

echo "Removing cgroups..."
cgdelete -g cpu,memory:/$CONTAINER_NAME

echo "Removing container..."
rm -rf $CONTAINER_NAME

echo "Done!"
