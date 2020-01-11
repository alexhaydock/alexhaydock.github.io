#!/bin/bash
set -xe

docker build -t alehaydock .

docker run --rm -it \
  --name "alexhaydock" \
  -v $(pwd)/:/opt/www/ \
  -p "127.0.0.1:4000:4000/tcp" \
  --workdir /opt/www \
  alexhaydock \
    bundle exec jekyll serve -H 0.0.0.0
