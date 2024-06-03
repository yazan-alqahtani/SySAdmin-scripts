#!/bin/bash

LOGFILE="/var/log/docker_cleanup.log"

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

log "Starting Docker cleanup..."

stopped_containers=$(docker ps -a -q)
if [ ! -z "$stopped_containers" ]; then
    docker rm $stopped_containers
    log "Removed stopped containers: $stopped_containers"
else
    log "No stopped containers to remove."
fi

dangling_images=$(docker images -f "dangling=true" -q)
if [ ! -z "$dangling_images" ]; then
    docker rmi $dangling_images
    log "Removed dangling images: $dangling_images"
else
    log "No dangling images to remove."
fi

unused_networks=$(docker network ls -q -f "dangling=true")
if [ ! -z "$unused_networks" ]; then
    docker network rm $unused_networks
    log "Removed unused networks: $unused_networks"
else
    log "No unused networks to remove."
fi

log "Docker cleanup completed."
