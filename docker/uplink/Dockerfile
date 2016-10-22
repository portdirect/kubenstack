FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

ENV OS_COMP="uplink"

COPY ./assets /opt/harbor/assets

RUN apk add --no-cache --virtual run-deps \
        iptables && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
