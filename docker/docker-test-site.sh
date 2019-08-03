#!/bin/bash
set -xe
if [ "$EUID" -ne 0 ]; then echo "This script requires root to issue Docker commands."; exit; fi

docker build -t alexhaydock .

docker run --rm -it \
  --name "alexhaydock" \
  -v "/home/a/gitlab/alexhaydock.co.uk:/opt/www" \
  -p "127.0.0.1:4000:4000/tcp" \
  alexhaydock \
    bundle exec jekyll serve --incremental -H 0.0.0.0
