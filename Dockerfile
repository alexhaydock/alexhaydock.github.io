FROM registry.gitlab.com/alexhaydock/dockerfiles:jekyll
LABEL maintainer "Alex Haydock <alex@alexhaydock.co.uk>"

# Install Gems for this site with Bundler
#
# This will install the latest Gems always since we're
# not including any Gemfile.lock from previous installs
#
COPY Gemfile /tmp/Gemfile
WORKDIR /tmp
RUN bundle install

# Serve site
WORKDIR /opt/www