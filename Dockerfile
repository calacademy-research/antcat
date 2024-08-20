FROM ruby:3.2.1-slim

ENV APP_PATH /app
ENV BUNDLER_VERSION 2.3.10

ARG ANTCAT_UID=1000
ARG ANTCAT_GID=1001
ENV ANTCAT_USER antcat
ENV ANTCAT_GROUP antcat

RUN groupadd --system ${ANTCAT_GROUP} --gid ${ANTCAT_GID}
RUN useradd --uid ${ANTCAT_UID} --system --create-home --no-log-init --gid ${ANTCAT_GROUP} ${ANTCAT_USER}

# Create subdir to fix openjdk ("error creating symbolic link '/usr/share/man/man1/java.1.gz.dpkg-tmp'"):
RUN mkdir -p /usr/share/man/man1

RUN apt-get update -qq && apt-get install -y \
  git \
  curl \
  vim \
  build-essential \
  default-libmysqlclient-dev \
  default-mysql-client \
  default-jre-headless

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
	  && apt-get install -y nodejs

RUN gem install bundler --version "$BUNDLER_VERSION"
RUN npm install -g yarn

RUN rake assete:precompile

WORKDIR $APP_PATH
