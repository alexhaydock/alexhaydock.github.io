#!/bin/sh

sudo docker build -t alexhaydock .

sudo docker run --rm -it \
  --name "alexhaydock" \
  -v "/home/a/code/alexhaydock.github.io:/opt/www" \
  -p "127.0.0.1:4000:4000/tcp" \
  alexhaydock \
    bundle exec jekyll serve --incremental -H 0.0.0.0
