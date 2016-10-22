FROM alpine:latest

ENV OS_DISTRO="HarborDev"

RUN cat /etc/apk/repositories > /etc/apk/repositories.bak && \
    apk add --no-cache --virtual core-deps \
        python \
        sudo \
        curl && \
        chmod 0640 /etc/sudoers && \
        sed -i '/Defaults    requiretty/s/^/#/' /etc/sudoers && \
        chmod 0440 /etc/sudoers && \
        python -m ensurepip && \
    apk add --no-cache --virtual build-deps1 \
        gcc \
        git \
        python-dev \
        linux-headers \
        libffi-dev \
        postgresql-dev \
        openssl-dev \
        libxml2-dev \
        libxslt-dev \
        curl \
        cmake \
        pkgconf \
        unzip \
        build-base \
        clang \
        clang-dev \
        zlib-dev && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache --virtual build-deps2 \
        libtbb \
        libtbb-dev && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    pip --no-cache-dir install ${PYTHON_XATTR_PACKAGE} && \
    CC="/usr/bin/clang" && \
    CXX="/usr/bin/clang++" && \
    LIBRARY_PATH="/lib:/usr/lib" && \
    pip --no-cache-dir install cython && \
    pip --no-cache-dir install numpy && \
    apk del build-deps1 && \
    apk del build-deps2 && \
    cat /etc/apk/repositories.bak > /etc/apk/repositories && \
    apk add --no-cache --virtual openstack-common-deps  \
        libxml2 \
        libxslt \
        libcurl \
        openssl && \
    pip --no-cache-dir install --upgrade pip setuptools && \
    pip install crudini && \
    pip install PyMySQL===0.7.5 && \
    pip install python-memcached

COPY ./assets /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

CMD ["/start.sh"]
