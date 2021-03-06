FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

ENV OS_COMP="horizon" \
    OS_REPO_URL="https://github.com/portdirect/horizon.git" \
    OS_REPO_BRANCH="master" \
    OS_COMP_1="neutron-lbaas-dashboard" \
    OS_REPO_URL_1="https://github.com/openstack/neutron-lbaas-dashboard.git" \
    OS_REPO_BRANCH_1="master"

RUN apk add --no-cache --virtual run-deps \
        apache2 && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        musl-dev \
        python-dev \
        linux-headers \
        libffi-dev \
        postgresql-dev \
        openssl-dev && \
    mkdir -p /opt/stack && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1} && \
    cp -f /opt/stack/${OS_COMP_1}/neutron_lbaas_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py \
          /opt/stack/horizon/openstack_dashboard/enabled/ && \
    pip install /opt/stack/${OS_COMP} && \
    pip install /opt/stack/${OS_COMP_1} && \
    apk del build-deps && \
    mkdir -p /var/log/${OS_COMP} && \
    addgroup ${OS_COMP} -g 1000 && \
    adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP}


RUN apk add --no-cache --virtual build-deps \
        git && \
    mkdir -p /opt/stack && \
    git clone --depth 1 https://github.com/patternfly/patternfly-sass.git /opt/patternfly-sass && \
        mkdir -p /opt/stack/horizon/openstack_dashboard/themes/harbor/static && \
        ln -s /opt/patternfly-sass/assets /opt/stack/horizon/openstack_dashboard/themes/harbor/static/ && \
    apk del build-deps



COPY ./assets /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets


RUN cfg=/opt/stack/horizon/openstack_dashboard/local/local_settings.py && \
    cp -f /opt/stack/horizon/openstack_dashboard/local/local_settings.py.build $cfg && \
    /opt/stack/horizon/manage.py collectstatic --noinput && \
    /opt/stack/horizon/manage.py compress && \
    rm -rf $cfg
