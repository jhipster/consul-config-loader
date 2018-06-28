FROM alpine:3.5
MAINTAINER Pierre Besson https://github.com/PierreBesson

RUN apk --update add nodejs git openssh curl bash inotify-tools jq && \
    rm -rf /var/cache/apk/* && \
    npm install -g simplywatch && \
    npm install -g git2consul@0.12.13 && \
    mkdir -p /etc/git2consul.d

ADD /load-config.sh /
VOLUME /config

ENV CONFIG_MODE=filesystem
ENV INIT_SLEEP_SECONDS=5
ENV CONSUL_URL=localhost
ENV CONSUL_PORT=8500
ENV CONFIG_DIR=/config

CMD /load-config.sh
