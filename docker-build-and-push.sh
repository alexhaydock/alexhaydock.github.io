#!/bin/bash
set -xe
if [ "$EUID" -eq 0 ]; then echo "Please do not run as root. Please add yourself to the 'docker' group."; exit; fi

docker build --no-cache -f Dockerfile-nginx -t registry.gitlab.com/alexhaydock/alexhaydock.co.uk .
docker push registry.gitlab.com/alexhaydock/alexhaydock.co.uk