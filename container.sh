#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script."
    exit 1
fi

if [[ $# -ne 2 ]]; then
    echo "Invalid number of args."
    echo "Usage: ./container.sh [container_name] [image_path]"
    echo "Currently, the image has to be a .tar.gz file."
    exit 2
fi

CONTAINER_NAME=$1
IMAGE_PATH=$2

# strip .tar.gz ending from IMAGE_PATH
IMAGE_NAME=$IMAGE_PATH
while [[ $IMAGE_NAME = *.* ]]
do
    IMAGE_NAME=${IMAGE_NAME%.*}
done

# setup directories for the overlayfs
mkdir $CONTAINER_NAME
chmod 777 $CONTAINER_NAME

mkdir $CONTAINER_NAME/image
mkdir $CONTAINER_NAME/upper
mkdir $CONTAINER_NAME/work
mkdir $CONTAINER_NAME/root

tar -xvzf $IMAGE_PATH -C $CONTAINER_NAME/image > /dev/null

# mount overlayfs
cd $CONTAINER_NAME
mount -t overlay overlay -o lowerdir=image,upperdir=upper,workdir=work root

# setup /dev, /sys, and /proc
cd image/rootfs
mount -t proc proc proc/
cd -

# unshare PID
unshare -p -f --mount-proc=$PWD/image/$IMAGE_NAME/proc chroot image/$IMAGE_NAME /bin/bash