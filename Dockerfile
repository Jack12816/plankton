FROM alpine:3.6
MAINTAINER Hermann Mayer <hermann.mayer92@gmail.com>

COPY . /app
WORKDIR /app

RUN apk add --update                                             \
  ruby ruby-dev ruby-bundler ruby-json                           \
  libstdc++ tzdata bash ca-certificates                          \
  build-base git                                                 \
  &&                                                             \
  bundle install --clean --without development                   \
  &&                                                             \
  apk del libstdc++ tzdata bash build-base

ENTRYPOINT /usr/bin/bundle exec exe/plankton
CMD help
