FROM debian as builder
LABEL maintainer "Alex Haydock <alex@alexhaydock.co.uk>"

# Set locale to solve 'US-ASCII' issue
# https://github.com/jekyll/jekyll/issues/4268#issuecomment-167258562
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Install Jekyll deps
RUN apt-get update && apt-get install -y bundler ruby-dev zlib1g-dev

# Copy site content into container
COPY . /tmp/alexhaydock.co.uk
WORKDIR /tmp/alexhaydock.co.uk

# Install the relevant gems with Bundler and then build the site
RUN bundle install
RUN bundle exec jekyll build

FROM nginx:stable-alpine
COPY --from=builder /tmp/alexhaydock.co.uk/_site /usr/share/nginx/html
