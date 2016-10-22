#!/bin/sh
set -e
################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Config"
################################################################################
source /opt/config-nova.sh


################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Waiting For DB"
################################################################################
wait-mysql


MASTER_IP=${EXPOSED_IP}
# mysql -h ${MARIADB_SERVICE_HOST} \
#       -u root \
#       -p"${DB_ROOT_PASSWORD}" \
#       mysql <<EOF
# DROP DATABASE IF EXISTS ${DB_NAME};
# EOF

mysql -h ${MARIADB_SERVICE_HOST} \
      -u root \
      -p"${DB_ROOT_PASSWORD}" \
      mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8 ;
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}' ;
CREATE DATABASE IF NOT EXISTS ${DB_NAME}_api DEFAULT CHARACTER SET utf8 ;
GRANT ALL PRIVILEGES ON ${DB_NAME}_api.* TO '${DB_USER}_api'@'%' IDENTIFIED BY '${DB_PASSWORD}' ;
EOF


################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Waiting For Public Keystone"
################################################################################
wait-http $KEYSTONE_SERVICE_HOST:5000


################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Patching IP Tables (by making the commands do nothing...)"
################################################################################
rm -rf /sbin/iptables
cat > /sbin/iptables <<EOF
#!/bin/sh
true
EOF
chmod +x /sbin/iptables

rm -rf /sbin/iptables-save
cat > /sbin/iptables-save <<EOF
#!/bin/sh
true
EOF
chmod +x /sbin/iptables-save
rm -rf /sbin/iptables-restore
cat > /sbin/iptables-restore <<EOF
#!/bin/sh
true
EOF
chmod +x /sbin/iptables-restore


################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: DB Management"
################################################################################
nova-manage --config-file $cfg --debug db sync
nova-manage --config-file $cfg --debug api_db sync


################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: launching"
################################################################################
exec nova-api --config-file $cfg --debug
