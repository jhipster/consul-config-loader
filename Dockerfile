FROM alpine:3.12
MAINTAINER Pierre Besson https://github.com/PierreBesson

RUN apk --update add nodejs npm git openssh curl bash inotify-tools jq && \
    rm -rf /var/cache/apk/* && \
    npm install -g simplywatch@2.5.7 && \
    npm install -g git2consul@0.12.13 && \
    mkdir -p /etc/git2consul.d

ADD /load-config.sh /
ADD /upload-consul-file.sh /
VOLUME /config

ENV CONFIG_MODE=filesystem
ENV INIT_SLEEP_SECONDS=5
ENV CONSUL_URL=localhost
ENV CONSUL_PORT=8500
ENV CONFIG_DIR=/config
ENV ENABLE_SPRING=true
ENV ENABLE_MICRONAUT=false

CMD /load-config.sh
