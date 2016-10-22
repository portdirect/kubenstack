#!/bin/sh
export OS_AUTH_URL="http://${KEYSTONE_SERVICE_HOST}:5000"
export OS_PROJECT_NAME="service"
export OS_PROJECT_DOMAIN_NAME="default"
export OS_USER_DOMAIN_NAME="default"
export OS_USERNAME="neutron"
export OS_PASSWORD="password"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

# Create network and attach a subnet
OCTAVIA_AMP_NETWORK_ID=$(neutron net-show lb-mgmt-net -f value -c id || neutron net-create lb-mgmt-net -f value -c id)
OCTAVIA_AMP_SUBNET_ID=$(neutron subnet-show lb-mgmt-subnet -f value -c id || neutron subnet-create \
--name lb-mgmt-subnet \
--allocation-pool start=$OCTAVIA_MGMT_SUBNET_START,end=$OCTAVIA_MGMT_SUBNET_END \
lb-mgmt-net $OCTAVIA_MGMT_SUBNET -f value -c id)
etcdctl set /octavia/controller_worker/amp_boot_network_list ${OCTAVIA_AMP_NETWORK_ID}


neutron security-group-show lb-mgmt-sec-grp -f value -c id ||  ( \
OCTAVIA_MGMT_SEC_GRP_ID=$(neutron security-group-create lb-mgmt-sec-grp -f value -c id)
neutron security-group-rule-create --protocol icmp ${OCTAVIA_MGMT_SEC_GRP_ID}
neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 ${OCTAVIA_MGMT_SEC_GRP_ID}
neutron security-group-rule-create --protocol tcp --port-range-min 9443 --port-range-max 9443 ${OCTAVIA_MGMT_SEC_GRP_ID}
)
OCTAVIA_MGMT_SEC_GRP_ID=$(neutron security-group-create lb-mgmt-sec-grp -f value -c id)
etcdctl set /octavia/controller_worker/amp_secgroup_list ${OCTAVIA_MGMT_SEC_GRP_ID}




neutron security-group-create lb-health-mgr-sec-grp
neutron security-group-rule-create \
--protocol udp --port-range-min 5555 \
--port-range-max 5555 lb-health-mgr-sec-grp
neutron port-create \
--name octavia-health-manager-standalone-listen-port \
--security-group lb-health-mgr-sec-grp \
--device-owner Octavia:health-mgr \
--binding:host_id=$(hostname) lb-mgmt-net | awk '/ id | mac_address / {print $4}'




MGMT_PORT_ID=$(neutron port-show octavia-health-manager-standalone-listen-port -f value -c id)
MGMT_PORT_MAC=$(neutron port-show octavia-health-manager-standalone-listen-port -f value -c mac_address)
MGMT_PORT_IP=192.168.0.12
sudo ovs-vsctl -- --may-exist add-port br-int o-hm0 -- set Interface o-hm0 type=internal -- set Interface o-hm0 external-ids:iface-status=active -- set Interface o-hm0 external-ids:attached-mac=$MGMT_PORT_MAC -- set Interface o-hm0 external-ids:iface-id=$MGMT_PORT_ID
sudo ip link set dev o-hm0 address $MGMT_PORT_MAC
sudo dhclient -v o-hm0 -cf $OCTAVIA_DHCLIENT_CONF

    
nova keypair-show octavia_ssh_key || ( \
mkdir -p /etc/octavia/.ssh
ssh-keygen -b 4096 -t rsa -N "" -f /etc/octavia/.ssh/octavia_ssh_key
SSH_PRIVATE_KEY_BASE64=$(cat /etc/octavia/.ssh/octavia_ssh_key | base64 | awk 1 ORS=' ')
SSH_PUBLIC_KEY_BASE64=$(cat /etc/octavia/.ssh/octavia_ssh_key.pub | base64 | awk 1 ORS=' ')
etcdctl set /octavia/ssh/private_key "${SSH_PRIVATE_KEY_BASE64}"
etcdctl set /octavia/ssh/public_key "${SSH_PUBLIC_KEY_BASE64}"
nova keypair-add --pub-key /etc/octavia/.ssh/octavia_ssh_key.pub octavia_ssh_key
)
