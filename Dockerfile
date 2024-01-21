FROM alpine:3.19.0
LABEL maintainer="Pierre Besson https://github.com/PierreBesson"

RUN apk --update --no-cache add nodejs npm git openssh curl bash inotify-tools jq && \
    npm install -g \
      simplywatch@2.5.7 \
      git2consul@0.12.13 && \
    mkdir -p /etc/git2consul.d

COPY load-config.sh upload-consul-file.sh /
VOLUME /config

ENV CONFIG_MODE=filesystem
ENV INIT_SLEEP_SECONDS=5
ENV CONSUL_URL=localhost
ENV CONSUL_PORT=8500
ENV CONFIG_DIR=/config
ENV ENABLE_SPRING=true
ENV ENABLE_MICRONAUT=false

CMD ["/load-config.sh"]
