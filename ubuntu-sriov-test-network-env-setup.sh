#!/bin/bash +e

# Please interconnect Mellanox PF0(ens6f0), PF1(ens6f1) for testing
# stop network-manager temporary
echo -e "\e[0;34mstopping network-manager for easy testing...\e[0m"
systemctl stop network-manager

# enable 4 VFs
echo -e "\e[0;31menabling 4 VFs...\e[0m"
echo 0 > /sys/class/net/ens6f1/device/sriov_numvfs
echo 4 > /sys/class/net/ens6f1/device/sriov_numvfs

# show the results
#lspci|grep "Mell"
ip l sh ens6f1


# setup ens6f1 ip address setting for isc-dhcp-server launching
echo -e "\e[0;33msetup PFs ip setting...\e[0m"
#ip l set dev ens6f0 up
ip addr flush dev ens6f0   #clear all addresses of the interface 'ens6f0'
ip addr add 192.168.5.200/24 dev ens6f0
ip addr flush dev ens6f1
ip addr add 192.168.5.205/24 dev ens6f1

# install dhcp server for testing
#apt-get install isc-dhcp-server -q -yy

# restart isc-dhcp-server for testing
# please edit /etc/dhcp/dhcpd.conf in first
echo -e "\e[0;32mstarting dhcp server for easy testing...\e[0m"
systemctl restart isc-dhcp-server

# show messages of isc-dhcp-server
journalctl -u isc-dhcp-server -n 30 --no-pager


