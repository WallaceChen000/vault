#!/bin/bash
# Setup network namespaces for devices with the same IP adress
# command-line: ./dev-setup-netns.sh ethernet-iface netns-label
# example:      ./dev-setup-netns.sh enp0s20u2 netns-dev1
#
# Task:
#       device interface ip is permament on device side: 192.168.1.1
#       host interface ip is permanent for device: 192.168.1.254
#       bridge ip address 10.0.0.254
#       netns internal ip on interface v${netns-label}-in will be defined from amount of network namespaces 10.0.0.{i+1}
#
# Tips:
#       to remove interface from bridge -> ip link set ${iface} nomaster
#       to show existed bridges and associated interfaces -> bridge link
#       to delete bridge interface -> ip link delete ${bridge-name} type bridge


if [ $# -lt 2 ]
then
    echo "Usage: $0 ethernet-iface netns-label"
    exit 1
else
    if [[ $(cat /sys/class/net/${1}/operstate | grep up) ]]
    then
        echo "Interface ${1} in use"
        exit 0
    elif [[ $(ip netns list | grep ${2}) ]]
    then
        echo "Network namespace ${2} exists!"
        exit 0
    fi
fi


netnslabel=$2
netns_ifdev=$1
# device interface in network namespace
netns_eth1="${netnslabel}-eth1"
# virtual pair for network namespace
vnetns_in="${netnslabel}-veth1"
vnetns_out="${netnslabel}-veth2"

ipaddr="10.0.0."$(expr $( ip netns list | wc -l ) + 1)



echo "Creating namespace with label ${netnslabel} and ethernet iface ${netns_ifdev}"

# rename iface
ip link set ${netns_ifdev} name ${netns_eth1}

# create netns
ip netns add ${netnslabel}

# put iface to netns
ip link set ${netns_eth1} netns ${netnslabel}

# setup ip for iface
ip netns exec ${netnslabel} ip addr add 192.168.1.254/24 dev ${netns_eth1}

# create iface pair
ip link add ${vnetns_out} type veth peer name ${vnetns_in}

# put insternatl to netns
ip link set ${vnetns_in} netns ${netnslabel}

# assign ip
ip netns exec ${netnslabel} ip addr ad ${ipaddr}/24 dev ${vnetns_in}

# create bridge
if [ ! -d /sys/class/net/dev-bridge ]; then
    ip link add name dev-bridge type bridge
    ip addr add 10.0.0.254/24 dev dev-bridge
fi

# add interface into the bridge
ip link set dev ${vnetns_out} master dev-bridge

# up all ifaces
ip link set dev-bridge up
ip link set ${vnetns_out} up
ip netns exec ${netnslabel} ip link set ${netns_eth1} up
ip netns exec ${netnslabel} ip link set ${vnetns_in} up

# default route in netns
ip netns exec ${netnslabel} ip ro add default via 10.0.0.254

# nat
ip netns exec ${netnslabel} iptables -t nat -A PREROUTING -i ${vnetns_in} -d ${ipaddr} -j DNAT --to-destination 192.168.1.1
ip netns exec ${netnslabel} iptables -t nat -A POSTROUTING -o ${netns_eth1} -j MASQUERADE
ip netns exec ${netnslabel} iptables -t nat -A PREROUTING -i ${netns_eth1} -d 192.168.1.254 -j DNAT --to-destination 10.0.0.254
ip netns exec ${netnslabel} iptables -t nat -A POSTROUTING -o ${vnetns_in} -j MASQUERADE

