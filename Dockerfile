FROM node:10-buster AS builder

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq update \
  && apt-get -y --no-install-recommends install \
      apt-transport-https \
      curl \
      unzip \
      build-essential \
      python \
      libcairo2-dev \
      libgles2-mesa-dev \
      libgbm-dev \
      libllvm7 \
      libprotobuf-dev \
  && apt-get -y --purge autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY . /usr/src/app

ENV NODE_ENV="production"

RUN cd /usr/src/app && npm install --production


FROM node:lts-alpine3.13 AS final

RUN export DEBIAN_FRONTEND=noninteractive \
  && apk update update \
  && apk add --no-cache --virtual \
      libgles2-mesa \
      libegl1 \
      xvfb \
      xauth \
  && apk cache clean

COPY --from=builder /usr/src/app /app

ENV NODE_ENV="production"
ENV CHOKIDAR_USEPOLLING=1
ENV CHOKIDAR_INTERVAL=500

VOLUME /data
WORKDIR /data

EXPOSE 80

USER node:node

ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["-p", "80"]
