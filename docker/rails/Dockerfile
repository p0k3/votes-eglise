FROM ruby:2.7.1

ENV BUNDLER_VERSION=2.3.13
ENV PYTHONPATH=/usr/bin/python3

RUN apt-get update -qq && \
    apt-get install -y apt-utils \
                       build-essential \
                       libpq-dev \
                       default-mysql-client

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
      apt-get install -y nodejs build-essential

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN gem install bundler -v "$BUNDLER_VERSION" && bundle install -j4

ADD . /app

EXPOSE 3000
