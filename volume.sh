#!/bin/bash

dir=/volumes
size=$1
name=$2
location=$dir/$name
mount_params='loop,rw,noatime,nodiratime'
volume_dir=/var/lib/docker/volumes/$name

error() {
    [ -z "$1" ] && echo "Usage: $(basename $0) size(MB) name" || echo $1
    exit 1
}

[[ ! $size =~ ^[0-9]+$ ]] || [[ ! $name =~ ^[a-zA-Z0-9_.-]+$ ]] && {
    error
}

[ -d $volume_dir ] && {
    error "Volume already exists in docker"
}

[ -f $location ] && {
    error "File already exists"
}

docker volume create $name && {
    dd of=$location bs=1M seek=$size count=0 &&
    mkfs.ext4 -F $location &&
    mount -t ext4 -n -o $mount_params $location $volume_dir/_data &&
    echo "$location /var/lib/docker/volumes/$name/_data ext4 $mount_params 0 0" >> /etc/fstab
}
