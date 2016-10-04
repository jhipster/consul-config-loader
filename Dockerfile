FROM alpine:3.4
MAINTAINER Pierre Besson https://github.com/PierreBesson

RUN apk --update add nodejs git openssh curl bash inotify-tools jq && \
    rm -rf /var/cache/apk/* && \
    npm install -g git2consul@0.12.12 && \
    mkdir -p /etc/git2consul.d

ADD load-config.sh /
ADD jhi-acl.json /
VOLUME /config

ENV CONFIG_MODE=filesystem
ENV INIT_SLEEP_SECONDS=5
ENV CONSUL_URL=localhost
ENV CONSUL_PORT=8500
ENV CONFIG_DIR=/config
ENV MASTER_ACL_TOKEN=to-change-in-production
ENV CLIENT_ACL_TOKEN=to-change-in-production-client

CMD /load-config.sh
