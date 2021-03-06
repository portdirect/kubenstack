FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

ENV OS_COMP="nova" \
    OS_REPO_URL="https://github.com/openstack/nova.git" \
    OS_REPO_BRANCH="stable/mitaka" \
    OS_COMP_1="nova-docker" \
    OS_REPO_URL_1="https://github.com/portdirect/nova-docker.git" \
    OS_REPO_BRANCH_1="master"

RUN cat /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache --virtual run-deps  \
        libxml2 \
        libxslt \
        libldap \
        libsasl \
        openssl \
        libcurl \
        docker \
        iproute2 \
        ethtool \
        openvswitch \
        sysfsutils \
        open-iscsi \
        util-linux && \
    apk add --no-cache --virtual management-deps  \
        mariadb-client \
        mariadb-client-libs && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        musl-dev \
        python-dev \
        linux-headers \
        libffi-dev \
        postgresql-dev \
        openssl-dev \
        libxml2-dev \
        libxslt-dev && \
    mkdir -p /opt/stack && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1} && \
    pip install /opt/stack/${OS_COMP} && \
    pip install /opt/stack/${OS_COMP_1} && \
    mkdir -p /etc/${OS_COMP}/ && \
    mkdir -p  /opt/stack/${OS_COMP}/etc/${OS_COMP}/ && \
    cp -rf /opt/stack/${OS_COMP}/etc/${OS_COMP}/* /etc/${OS_COMP}/ && \
    apk del build-deps && \
    mkdir -p /var/log/${OS_COMP} && \
    mkdir -p /var/lib/${OS_COMP}/lock && \
    mkdir -p /var/lib/${OS_COMP}/instances && \
    addgroup ${OS_COMP} -g 1000 && \
    adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP}

COPY ./assets /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    ln -s /usr/sbin/iscsid /sbin/iscsid
