FROM ruby:2.3.3

ENV WORKDIR "/antcat"

RUN apt-get update -qq && apt-get install -y nodejs mysql-client qt5-default libqt5webkit5-dev qtchooser netcat

WORKDIR $WORKDIR

# Make sure files are not owned by root because that has issues.
RUN groupadd --system antcat --gid 1000
RUN useradd --uid 1000 --system --create-home --no-log-init --gid antcat antcat

# Add `/cache/version.json` to bust the cache whenever there's new code on GitHub.
ADD https://api.github.com/repos/calacademy-research/antcat/git/refs/heads/master /cache/version.json

# Fetch code from GitHub. This is not 100% correct since there may be undeployed code on master.
# See `cat /data/antcat/current/REVISION` on EngineYard for the currently deployed commit.
RUN git clone --depth 1 --branch master https://github.com/calacademy-research/antcat.git .

RUN bundle install

# Copy local docker subdir because it's used in the code right now since but it's not on GH yet.
# TODO: Maybe remove. Maybe keep.
COPY ./docker "$WORKDIR/docker"

# ----------
# Uncomment this and comment out the above to copy files from local machine.
# COPY Gemfile* "$WORKDIR/"
# RUN bundle install
# COPY . "$WORKDIR"
# ----------

COPY ./docker/config/database.yml "$WORKDIR/config/database.yml"

# Uncomment this to debug the whole export (and edit the file to only export the first 100 records).
# COPY ./app/services/exporters/antweb/exporter.rb "$WORKDIR/app/services/exporters/antweb/exporter.rb"

RUN chown -R antcat:antcat "$WORKDIR"

ARG SSH_PRIVATE_KEY
RUN mkdir /home/antcat/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /home/antcat/.ssh/id_rsa

USER antcat
