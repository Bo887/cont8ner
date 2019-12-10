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
cd image
mount -t proc proc proc/
#mount --bind /sys sys/
#mount --bind /dev dev/
cd -

# setup networking
VETH="veth${CONTAINER_NAME}"
VPEER="vpeer${CONTAINER_NAME}"
VETH_ADDR="10.200.1.1"
VPEER_ADDR="10.200.1.2"
IFACE="wlp8s0"

ip netns add $CONTAINER_NAME

ip link add ${VETH} type veth peer name ${VPEER}
ip link set ${VPEER} netns $CONTAINER_NAME
ip addr add ${VETH_ADDR}/24 dev ${VETH}
ip link set ${VETH} up
ip netns exec $CONTAINER_NAME ip addr add ${VPEER_ADDR}/24 dev ${VPEER}
ip netns exec $CONTAINER_NAME ip link set ${VPEER} up
ip netns exec $CONTAINER_NAME ip link set lo up
ip netns exec $CONTAINER_NAME ip route add default via ${VETH_ADDR}
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -P FORWARD DROP
iptables -F FORWARD
iptables -t nat -F
iptables -t nat -A POSTROUTING -s ${VPEER_ADDR}/24 -o ${IFACE} -j MASQUERADE
iptables -A FORWARD -i ${IFACE} -o ${VETH} -j ACCEPT
iptables -A FORWARD -o ${IFACE} -i ${VETH} -j ACCEPT

# unshare in the new network namespace
ip netns exec ${CONTAINER_NAME} unshare -p -f --mount-proc=$PWD/image/proc chroot image/ /bin/bash
