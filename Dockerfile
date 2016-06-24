FROM debian:7.10

RUN apt-get update -qq && apt-get install -y locales -qq && locale-gen en_US.UTF-8 en_us && dpkg-reconfigure locales && dpkg-reconfigure locales && locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update -qq && apt-get install -y \
  ruby \
  build-essential \
  libpq-dev \
  git \
  libxml2-dev \
  libxslt1-dev \
  libsqlite3-dev \
  bundler \
  curl \
  libfreetype6 \
  libfreetype6-dev \
  libfontconfig1 \
  libfontconfig1-dev

RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD install_phantomjs_if_missing.rb /myapp/install_phantomjs_if_missing.rb
RUN ruby install_phantomjs_if_missing.rb
ADD . /myapp
