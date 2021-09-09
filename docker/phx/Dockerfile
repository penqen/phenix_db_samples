# working directory on container
ARG WORKDIR=/app
# application root directory on host
ARG APP_ROOT=./sample
# version of phx.new
ARG PHX_NEW_VERSION=1.5.12

# base image
FROM elixir:1.12.2-alpine AS base

ARG WORKDIR
ARG APP_ROOT
ARG PHX_NEW_VERSION
ENV WORKDIR=${WORKDIR}
ENV APP_ROOT=${APP_ROOT}

RUN \
  apk add --update-cache --no-cache inotify-tools \
  && mix local.hex --force \
  && mix local.rebar --force

ENTRYPOINT [ "mix" ]
CMD [ "help" ]

# phx.new image
FROM base AS phx.new

ARG PHX_NEW_VERSION
ENV PHX_NEW_VERSION=${PHX_NEW_VERSION}

WORKDIR ${WORKDIR}
RUN mix archive.install hex phx_new ${PHX_NEW_VERSION} --force

ENTRYPOINT [ "mix" ]
CMD [ "help", "phx.new" ]

# development image
FROM base AS development

ARG WORKDIR
ARG APP_ROOT
ENV MIX_ENV=dev
WORKDIR ${WORKDIR}

COPY ${APP_ROOT}/config ./config
COPY ${APP_ROOT}/mix.* ./

RUN mix do deps.get, deps.compile

EXPOSE 4000

ENTRYPOINT [ "mix" ]
CMD [ "phx.server" ]

# development image with node
FROM base AS development.node

ARG WORKDIR
ARG APP_ROOT
ENV MIX_ENV=dev
WORKDIR ${WORKDIR}

RUN \
  apk add --update-cache --no-cache \
  nodejs \
  npm 

COPY ${APP_ROOT}/config ./config
COPY ${APP_ROOT}/mix.* .
COPY ${APP_ROOT}/assets/package*.json ./assets/

RUN mix do deps.get, deps.compile

EXPOSE 4000

ENTRYPOINT [ "mix" ]
CMD [ "phx.server" ]