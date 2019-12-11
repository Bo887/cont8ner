#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Invalid number of args."
    echo "Usage: ./init_container.sh [user_name]"
    exit 2
fi

USER_NAME=$1

echo "Setting up user $USER_NAME..."
adduser $USER_NAME

ulimit -u 1024

/bin/bash
