FROM registry.gitlab.com/prod.docker/jekyll:latest as builder

# Copy site content into container
COPY . /tmp/alexhaydock.co.uk
WORKDIR /tmp/alexhaydock.co.uk

# Install the relevant gems with Bundler and then build the site
RUN bundle install
RUN bundle exec jekyll build

FROM nginx:stable-alpine
LABEL maintainer "Alex Haydock <alex@alexhaydock.co.uk>"
LABEL name "alexhaydock.co.uk"
LABEL version "1.0"

COPY --from=builder /tmp/alexhaydock.co.uk/_site /usr/share/nginx/html
